import functools
import numpy as np
cimport numpy as np

from scipy.interpolate import griddata

DTYPE = np.float64

def get_t(y,a,b):
    return np.pi - np.arcsin(y/b)

def interpolate(np.ndarray[np.float64_t, ndim=2] img,int x,int y,int r):
    grid_x,grid_y = np.mgrid[0:len(img[1,:]):1,0:len(img):1]
    points = np.where(img!=0)
    values = img[points]
    intrp = griddata(points, values, (grid_x, grid_y), method='linear')
    return intrp

def zoom_cy2(int a, img,int x,int y,int r,
         int precision,double xi):
    """
    Calcula rayos. sqrt(...)<r/rel
    """
    cdef np.ndarray[np.float64_t, ndim=2] zoomed
    cdef np.ndarray[np.float64_t, ndim=1] v1
    cdef int y_f,x_f
    cdef double theta,increment
    cdef Py_ssize_t line,Y,xp,yp

    zoomed = np.zeros((r*2+1,r*2+1), dtype=DTYPE)
    y_f = int(zoomed.shape[0]+1)/2
    x_f = int(zoomed.shape[1]+1)/2
    v1 = np.array([1,0], dtype=DTYPE)
    theta = 0.0
    increment = np.pi/precision
    new_y = [0]
    for Y in range(1,r):
        t1 = get_t(Y,a,r)
        c = np.cos(t1)
        th1 = np.arccos(-c)
        xx = a*c
        v = Y-int((xi-xx)*np.tan(th1))
        if abs(v) < r:
            new_y.append(v)
        else:
            break

    for line in range(precision):
        for Y in range(len(new_y)):

            # up
            pos1 = [int(Y*v1[1]),int(Y*v1[0])]
            xp = int(y_f+new_y[Y]*v1[1])
            yp = int(x_f+new_y[Y]*v1[0])
            zoomed[xp,yp] = img[y+pos1[0],x+pos1[1]]

            #down
            pos1 = [int(-Y*v1[1]),int(-Y*v1[0])]
            xp = int(y_f-new_y[Y]*v1[1])
            yp = int(x_f-new_y[Y]*v1[0])
            zoomed[xp,yp] = img[y+pos1[0],x+pos1[1]]

        theta+=increment
        v1[0] = np.cos(theta)
        v1[1] = np.sin(theta)

    return zoomed

