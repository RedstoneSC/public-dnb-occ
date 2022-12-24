from PIL import Image
import os

# made and edited (for this mod) by me, but you dont need to credit if you use this script

icons = os.listdir("./")

for iconNum in range(len(icons)):
    imageNameRaw = icons[iconNum]
    if not imageNameRaw.endswith(".png") or not imageNameRaw.startswith("icon-") or imageNameRaw.lower() == "icon-.png":
        continue
    image = Image.open(imageNameRaw)
    print(image)
    if image.size[0] == image.size[1]:
        image = image.resize((512, 512))
    elif image.size[0] / 2 == image.size[1]:
        image = image.crop((0, 0, int(image.size[0] / 2), image.size[1]))
        image = image.resize((512, 512))
    else:
        image = image.crop((0, 0, int(image.size[0] / 3), image.size[1]))
        image = image.resize((512, 512))
    print(image)
    image.save("rpcicons/" + imageNameRaw.replace("icon-", ""))
