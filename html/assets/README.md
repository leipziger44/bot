# Assets Folder

This folder contains additional assets for the Modern HUD:

## Folder Structure
- `/icons/` - Custom icons for the HUD elements
- `/sounds/` - Sound effects for notifications (optional)
- `/images/` - Background images or textures (optional)

## Usage
Place any custom assets in their respective folders and reference them in the CSS or JavaScript files.

## Minimap Textures
For custom minimap styling, you can add custom radar mask textures here. Make sure to update the client.lua file to reference the correct texture paths.

## Example:
```lua
-- In client.lua, modify the minimap section:
RequestStreamedTextureDict('your-custom-texture-dict', false)
```

## Notes
- Keep file sizes small for optimal performance
- Use compressed formats (WebP for images, compressed audio)
- Test all assets in-game before deployment