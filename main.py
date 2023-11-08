import sys,getopt
sys.path.append('./lente')
import numpy as np
import cv2 as cv
import utils as lu2

def usage():

    print("""
          USAGE: python3 main.py -i <path_to_image>

          OPTIONS:
            -h, --help
            -i, --image <path_to_image>
            -p, --precision <precision> (must be int. CAUTION! Too high precision can affect performance)

          """)

def mouse_ctrl(event,x,y,flags,param):
    """
    Function executed as a response to moues events
    """

    global img,r,precision,xo,f,drawing,xi

    if event == 1: # toggle magnifying glass
        drawing = not drawing
        cv.imshow("image",img)

    if event == 0 and drawing: # magnifying glass activated
        img1 = np.array(img)
        z = lu2.zoom_cy2(1,img1,x,y,r,precision,xi)
        z1 = lu2.interpolate(z,x,y,r)
        #z = lu.laplace_diag(z)
        mask = np.where(np.isnan(z1) == False)
        mask_img = (mask[0]+y-r,mask[1]+x-r)
        img1[mask_img] = z1[mask]
        cv.imshow("image",img1)

if __name__ == "__main__":

    img = None
    precision = 70

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hi:p:", ["help","image=","precision="])
    except getopt.GetoptError as err:
        print(err)  
        #usage()
        sys.exit(2)

    for o, a in opts:
        if o in ("-h", "--help"):
            print("""
          MAGNIFYING GLASS

          Click on the image to toggle the maginfying glass.
          Use 'a' key to magnify and 's' key to reduce. (Or change the key bindings in the code)
                  """)
            usage()
            sys.exit()
        elif o in ("-i", "--image"):
            img = cv.imread(a,0)
        elif o in ("-p", "--precision"):
            precision = int(a)
        else:
            assert False, "unhandled option"

    if img is None:
        print("Must specify an image!")
        usage()
        print("Aborting...")
        sys.exit(2)

    y = int(len(img)/2)
    x = int(len(img[0])/2)

    r = int(len(img)/9)
    xo = 5
    f = 10
    drawing = False
    xi = -25


    cv.namedWindow('image') 
    cv.setMouseCallback('image',mouse_ctrl)
    cv.imshow('image',img)
    while(1):
        key = cv.waitKey(20)
        if key & 0xFF == 27:
            break
        if key == ord('a'):
            xi-=5
            cv.imshow('image',img)
        elif key == ord('s'):
            xi+=5
            cv.imshow('image',img)
    cv.destroyAllWindows()
