#!/usr/bin/env python3
"""Offline structure check for Scratchworks model releases; does not run Roblox."""
import sys,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).resolve().parents[1]
for model in sorted((root/'models').glob('*.rbxmx')):
    tree=ET.parse(model)
    items=list(tree.iter('Item'))
    scripts=[it for it in items if it.get('class') in ('Script','LocalScript','ModuleScript')]
    print(f'{model.name}: {len(items)} Roblox instances, {len(scripts)} embedded scripts')
    assert items and scripts, f'Empty or unusable model: {model}'
print('XML and script-presence checks passed; run functional tests in Roblox Studio.')
