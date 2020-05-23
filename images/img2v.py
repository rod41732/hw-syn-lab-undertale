# source: https://www.ece.ucdavis.edu/~bbaas/180/tutorials/image.bitmaps/img2v.py
"""
This python script requires the opencv-python module (cv2) to run.
To install this module on OSX/Linux systems, type the following in a
terminal window: pip install opencv-python

2019/06/01 Written. (Arthur Hlaing)
2019/06/03 Removed need for math module, added command line arguments. (AH)
"""

import cv2
import numpy as np
import sys

if len(sys.argv) != 5:
    print("Error: required 4 arguments but provided %s arguments." % str(len(sys.argv) - 1))
    print("Usage: python img2v.py OUT_MODE SIZE_X SIZE_Y IMAGE_FILENAME > OUT_FILENAME.v" )
    print("       OUT_MODE=0      For use in a case statement" )
    print("       OUT_MODE=1      For use in an initial block" )
    print("       SIZE_X, SIZE_Y  Image will be scaled to this size in pixels" )
    print("Example: python img2v.py 0 16 16 mario.jpg > rom.v" )
    quit()    

IMAGE_FILENAME = sys.argv[4] # input image file name
IMAGE_SHAPE = (int(sys.argv[2]),int(sys.argv[3]))
MODE = int(sys.argv[1])

def dec2bin(x, length):
    # remove "0b" from string
    tmp = bin(x)[2:]
    # append leading 0s if four binary bits are not present
    for i in range(0, length - len(tmp)):
        tmp = "0" + tmp
    return tmp
img = cv2.imread(IMAGE_FILENAME)
if img is None:
    print("Error: %s cannot be read." % (IMAGE_FILENAME))
    quit()
# crop image to square
# # if height is greater than width, crop height same length as width
# if img.shape[0] > img.shape[1]:
#     midpoint = int(img.shape[0]/2)
#     left = midpoint-int(img.shape[1]/2)
#     right = midpoint+int(img.shape[1]/2)
#     img = img[left:right,:,:]
# # if width is greater than height, make width same length as height
# elif img.shape[1] > img.shape[0]:
#     midpoint = int(img.shape[1]/2)
#     left = midpoint-int(img.shape[0]/2)
#     right = midpoint+int(img.shape[0]/2)
#     img = img[:,left:right,:]
# resize image to 16x16
img = cv2.resize(img, IMAGE_SHAPE)

#--- Uncomment the four lines below to show the image. Press q key to quit.
# cv2.imshow("hello", img)
# key = cv2.waitKey(0)
# while key not in [ord('q')]:
#    key = cv2.waitKey(0)
#--- Uncomment the four lines above to show the image. Press q key to quit.

addr = 0
for h in range(0, img.shape[0]):
    # print() # 1 = white, 0 = red
    for w in range(0, img.shape[1]):
        # map from between 0 and 255 to between 0 and 15 (4 bits)
        blue = dec2bin(int((img[h,w,0]/255) * 15), 4)
        green = dec2bin(int((img[h,w,1]/255) * 15), 4)
        red = dec2bin(int((img[h,w,2]/255) * 15), 4)
        if MODE:
            # distinguish btw white & black
            # print("3" if red >= '0011' else "0")
            # distinguish btw red and white
            print("1" if green >= '0011' else 0)
        else:
            print(str(int(np.log2(IMAGE_SHAPE[0]*IMAGE_SHAPE[1]))) + "'b" + dec2bin(addr, 8) + ": begin mem = 12'b" + red + "_" + green + "_" + blue + "; end" )
        addr += 1

