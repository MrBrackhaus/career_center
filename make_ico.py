from PIL import Image

# For the .exe icon, we use Concept 1 (Dark) as the primary icon
img = Image.open('assets/images/logo_dark.jpg')

# .ico files usually contain multiple sizes
icon_sizes = [(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)]

# Save as .ico
img.save('windows/runner/resources/app_icon.ico', format='ICO', sizes=icon_sizes)
print("Saved app_icon.ico")
