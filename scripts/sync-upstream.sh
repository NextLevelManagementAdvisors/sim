#!/usr/bin/env bash
# Pull upstream simstudioai/sim changes into this fork's main branch.
# Resolve any conflicts with our patches in apps/sim/{lib/api-key/byok.ts,
# lib/copilot/tools/mcp/definitions.ts, app/api/mcp/copilot/route.ts,
# app/api/copilot/api-keys/{route,generate/route}.ts, blocks/utils.ts,
# app/workspace/[workspaceId]/settings/navigation.ts}.
#
# Run from the repo root.
set -euo pipefail

if ! git remote | grep -q '^upstream$'; then
  echo "Adding upstream remote (simstudioai/sim)..."
  git remote add upstream https://github.com/simstudioai/sim.git
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "main" ]; then
  echo "Switching to main (was on $current_branch)..."
  git checkout main
fi

echo "Fetching upstream..."
git fetch upstream main

ahead=$(git rev-list --count upstream/main..main)
behind=$(git rev-list --count main..upstream/main)
echo "main is $ahead ahead, $behind behind upstream/main"

if [ "$behind" -eq 0 ]; then
  echo "Already up to date with upstream. Nothing to do."
  exit 0
fi

echo
echo "Merging upstream/main into main..."
if git merge upstream/main --no-edit; then
  echo "Merge clean."
else
  echo
  echo "MERGE CONFLICT. Resolve in editor, then:"
  echo "  git add <files>"
  echo "  git commit"
  echo "  git push origin main"
  echo
  echo "After push, on the VPS:"
  echo "  cd /opt/sim-build && git pull"
  echo "  docker build -f docker/app.Dockerfile -t simstudio-byok:latest ."
  echo "  cd /opt/sim && docker compose up -d --force-recreate simstudio"
  exit 1
fi

echo
echo "Pushing main..."
git push origin main

echo
echo "Done. Now on VPS run:"
echo "  ssh root@178.16.141.166 'cd /opt/sim-build && git pull && docker build -f docker/app.Dockerfile -t simstudio-byok:latest .'"
echo "  ssh root@178.16.141.166 'cd /opt/sim && docker compose up -d --force-recreate simstudio'"
