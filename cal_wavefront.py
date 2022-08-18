#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 17 15:25:45 2022 

@author:Tim Lin
@email:jiunting@uoregon.edu

"""

from obspy.taup import TauPyModel
import obspy
import numpy as np

vel_mod = TauPyModel(model="/Users/jtlin/Documents/Project/MLARGE/data/Vel1D_Chile.npz") 
evlo, evla, evdp = -72.898, -36.122, 22.9

sav_time = []
dx = dy = 0.25
for stlo in np.arange(-77-dx,-69.5+dx,dx):
    print(stlo)
    for stla in np.arange(-43.0-dy,-30+dy,dy):
        print(' ',stla)
        d = obspy.geodetics.locations2degrees(lat1=evla,long1=evlo,lat2=stla,long2=stlo)
        P = vel_mod.get_travel_times(source_depth_in_km=evdp, distance_in_degree=d, phase_list=('P','p'), receiver_depth_in_km=0)
        S = vel_mod.get_travel_times(source_depth_in_km=evdp, distance_in_degree=d, phase_list=('S','s'), receiver_depth_in_km=0)
        if (len(P)!=0) and (len(S)!=0):
            sav_time.append([stlo,stla,P[0].time,S[0].time])


sav_time = np.array(sav_time)

#2D interpolation
from scipy.interpolate import griddata,interp2d

def get_XYZ(x,y,z,stype=1,thres=1e-5):
    #x,y,z are array-like and can be plotted by plt.scatter(x,y,c=z)
    #convert the format of x,y,z to X,Y,Z so that you can use plt.pcolor(X,Y,Z)
    #stype=sort type, fix x first and loop through y? stype=1, otherwise stype=2
    #threshold of how large as considered different point?
    X=[]
    for ix in x:
        if X==[]:
            X.append(ix)
            X=np.array(X)
        else:
            diff=np.abs(ix-X) #the difference between this point to the previous array
            if len(np.where(diff<thres)[0]>=1):
                continue
            else:
                X=np.hstack([X,ix])
    Y=[]
    for iy in y:
        if Y==[]:
            Y.append(iy)
            Y=np.array(Y)
        else:
            diff=np.abs(iy-Y) #the difference between this point to the previous array
            if len(np.where(diff<thres)[0]>=1):
                continue
            else:
                Y=np.hstack([Y,iy])
    #X=np.unique(x) #you can use unique if the data are perfectly gridded e.g. x=[0.000001 0.000001.....0.000002]; not [0.0000012 0.0000011 0.000001102], though they are close
    #Y=np.unique(y)
    z=np.array(z)
    if stype=='auto':
        if  (( (x[1]-x[0])<=thres) & ( (y[1]-y[0])>thres ) ) :
            stype=1
        elif (( (x[1]-x[0])>thres) & ( (y[1]-y[0])>thres) ):
            stype=2
        else:
            print('fail to determine the order!!, please check')
            if (x[1]-x[0])<(y[1]-y[0]):
                stype=1
            else:
                stype=2
    if stype==1:
        Z=z.reshape(len(X),len(Y))
        Z=Z.transpose()
    elif stype==2:
        Z=z.reshape(len(Y),len(X))
    else:
        print('please specific sort type of your Z by plot(x) or plot(y)')
    return(X,Y,Z)

X,Y,P = get_XYZ(sav_time[:,0],sav_time[:,1],sav_time[:,2],stype=1,thres=0.01)
X,Y,S = get_XYZ(sav_time[:,0],sav_time[:,1],sav_time[:,3],stype=1,thres=0.01)

fP = interp2d(X, Y, P, kind='cubic') #the base interpolate function
fS = interp2d(X, Y, S, kind='cubic') #the base interpolate function
# define new sampling rate
sampl = 0.05
X2 = np.arange(np.min(X),np.max(X)+sampl,sampl) #new sampling is 0.5 km
Y2 = np.arange(np.min(Y),np.max(Y)+sampl,sampl)
P2 = fP(X2, Y2) # start interpolate for P
S2 = fS(X2, Y2) # for S

# get lon,lat for particular P,S time e.g. want to know the lon/lat at P=30


T = np.arange(102)*5+5
sav_xy_P = []
sav_xy_S = []
for it,t in enumerate(T):
    fout = open('./Maule_wavefront/P%03d.txt'%(it),'w')
    # P contour
    C = plt.contour(X2,Y2,P2,levels=[t])
    plt.close()
    Ps = C.collections[0].get_paths()
    all_v = []
    for j in range(len(Ps)):
        v = Ps[j].vertices
        if all_v==[]:
           all_v = v[:]
        else:
            all_v = np.vstack([all_v,v])
        for iv in v:
            fout.write('%f %f \n'%(iv[0],iv[1]))
        fout.write('>\n')
        #plt.plot(v[:,0],v[:,1],label='T=%d'%(t))
    sav_xy_P.append(all_v)
    fout.close()
    # S contour
    fout = open('./Maule_wavefront/S%03d.txt'%(it),'w')
    C = plt.contour(X2,Y2,S2,levels=[t])
    plt.close()
    Ps = C.collections[0].get_paths()
    all_v = []
    for j in range(len(Ps)):
        v = Ps[j].vertices
        if all_v==[]:
           all_v = v[:]
        else:
            all_v = np.vstack([all_v,v])
        for iv in v:
            fout.write('%f %f \n'%(iv[0],iv[1]))
        fout.write('>\n')
        #plt.plot(v[:,0],v[:,1],label='T=%d'%(t))
    sav_xy_S.append(all_v)
    fout.close()







