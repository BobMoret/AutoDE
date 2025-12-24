Hit the arrow next to the green code button and select download ZIP.
Extract AutoDE-main.zip and in this directory copy the AutoDE directory in to your addon folder.

# AutoDE v8.4.6
# Alt + Leftclick Disenchant items with blacklist option. Alt + Leftclick lockpicking for WoW Ascention.
## Final input model (verified)

- SecureActionButton **must be mouse-enabled** to receive LeftClick.
- It **must not stay mouse-enabled** when idle, or it blocks RightClick.

### Therefore:
- Mouse is enabled on `OnShow`
- Mouse is disabled on `OnHide`

This exactly mirrors Molinari's implementation.

## Controls
- Alt + LeftClick → Disenchant / Lockbox
- Alt + RightClick → Toggle blacklist
