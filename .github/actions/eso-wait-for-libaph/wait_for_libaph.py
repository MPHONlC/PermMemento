import argparse
import datetime
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = 'https://api.github.com'
ACTIVE = {'queued', 'in_progress', 'waiting', 'requested', 'pending'}
DAILY = re.compile(r"cron:\s*['\"]?(\d{1,2})\s+(\d{1,2})\s+\*\s+\*\s+\*['\"]?")


def get(url, token, raw=False):
    headers = {'Accept': 'application/vnd.github.raw' if raw else 'application/vnd.github+json',
               'User-Agent': 'eso-wait-for-libaph', 'X-GitHub-Api-Version': '2022-11-28'}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=30) as response:
        return response.read().decode('utf-8', 'replace')


def due_today(repo, ref, workflow, token, now):
    try:
        text = get('%s/repos/%s/contents/.github/workflows/%s?ref=%s' % (API, repo, workflow, urllib.parse.quote(ref)), token, raw=True)
    except urllib.error.HTTPError:
        return None
    times = []
    for minute, hour in DAILY.findall(text):
        at = now.replace(hour=int(hour), minute=int(minute), second=0, microsecond=0)
        if at <= now:
            times.append(at)
    return max(times) if times else None


def stamp(text):
    return datetime.datetime.strptime(text, '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=datetime.timezone.utc)


def created(run):
    return stamp(run['created_at'])


def still_busy(args, token, now, born):
    busy = []
    late = datetime.timedelta(minutes=args.late_minutes)
    since = (now - datetime.timedelta(days=1)).strftime('%Y-%m-%d')
    for workflow in args.workflows.split():
        try:
            data = json.loads(get('%s/repos/%s/actions/workflows/%s/runs?per_page=30&created=%s' % (
                API, args.repo, workflow, urllib.parse.quote('>=' + since)), token))
        except urllib.error.HTTPError as err:
            if err.code == 404:
                continue
            raise
        runs = data.get('workflow_runs', [])
        active = [r for r in runs if r.get('status') in ACTIVE]
        if active:
            busy.append('%s is %s (%s)' % (workflow, active[0]['status'], active[0].get('html_url', '')))
            continue
        due = due_today(args.repo, args.ref, workflow, token, now)
        if due and born < due and now - due < late and not any(r.get('event') == 'schedule' and created(r) >= due - datetime.timedelta(minutes=1) for r in runs):
            busy.append('%s was due at %s UTC and has not started yet' % (workflow, due.strftime('%H:%M')))
    return busy


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', required=True)
    parser.add_argument('--ref', default='main')
    parser.add_argument('--workflows', required=True)
    parser.add_argument('--timeout-minutes', type=float, default=120)
    parser.add_argument('--poll-seconds', type=float, default=30)
    parser.add_argument('--late-minutes', type=float, default=120)
    args = parser.parse_args()
    token = os.environ.get('GH_TOKEN', '')
    if os.environ.get('GITHUB_REPOSITORY', '').lower() == args.repo.lower():
        print('This is %s itself, nothing to wait for.' % args.repo)
        return 0
    try:
        born = stamp(json.loads(get('%s/repos/%s' % (API, args.repo), token))['created_at'])
    except Exception as err:
        print('::warning title=Could not read %s::%s. Going on with what %s has published now.' % (args.repo, err, args.repo))
        return 0
    deadline = time.time() + args.timeout_minutes * 60
    waited = False
    while True:
        now = datetime.datetime.now(datetime.timezone.utc)
        try:
            busy = still_busy(args, token, now, born)
        except Exception as err:
            print('::warning title=Could not read %s runs::%s. Going on with what %s has published now.' % (args.repo, err, args.repo))
            return 0
        if not busy:
            print('%s has finished today\'s runs%s; going on.' % (args.repo, ' after waiting' if waited else ''))
            return 0
        if time.time() >= deadline:
            print('::warning title=%s still busy::Waited %d minutes; going on with what %s has published now. %s'
                  % (args.repo, args.timeout_minutes, args.repo, '; '.join(busy)))
            return 0
        print('Waiting for %s: %s' % (args.repo, '; '.join(busy)))
        sys.stdout.flush()
        waited = True
        time.sleep(args.poll_seconds)


if __name__ == '__main__':
    sys.exit(main())
