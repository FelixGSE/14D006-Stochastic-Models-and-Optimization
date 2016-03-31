# -*- coding: utf-8 -*-
"""
Created on Wed Mar 30 19:48:20 2016

@author: felix
"""
############################################################################
# Packages
############################################################################

import matplotlib.pyplot as plt  

############################################################################
# Studying different Learning Rates - No randomisation 
############################################################################

eps   = 0 
alp01 = 0.2

p01 = Learner(player = 1, alpha = alp01, epsilon = eps)
p02 = Learner(player = 2, alpha = alp01, epsilon = eps)
g02 = Game(learner = p01 , other = p02 )

lb  = 5
ub  = 10
it  = range( lb , ub )
s01 = []

for i in it:
    p01 = Learner(player = 1, alpha = alp01, epsilon = eps)
    p02 = Learner(player = 2, alpha = alp01, epsilon = eps)
    g01 = Game(learner = p01 , other = p02 )
    g01.selfplay(i)
    w = g01.sp.wining
    w01 = float( len([i for i in range(len(w)) if w[i] == 1]) ) / float( len(w)) * 100
    w02 = float( len([i for i in range(len(w)) if w[i] == 2]) ) / float( len(w)) * 100
    w00 = float( len([i for i in range(len(w)) if w[i] == 0]) ) / float( len(w)) * 100
    temp = [ w01,w02,w00 ]
    s01.append(temp)
  
x = it
# Add the lines 
plt.plot(it, [row[0] for row in s01])
plt.plot(it, [row[1] for row in s01])
plt.plot(it, [row[2] for row in s01])

# Remove plot frame lines and axis ticks
ax = plt.subplot(111)    
ax.spines["top"].set_visible(False)    
ax.spines["bottom"].set_visible(False)    
ax.spines["right"].set_visible(False)    
ax.spines["left"].set_visible(False)       
ax.get_xaxis().tick_bottom()    
ax.get_yaxis().tick_left()  

# X and Y lim  
plt.ylim(0, 100)
plt.xlim(0,max(it))    
  
for y in range(10, 91, 10):    
    plt.plot(it, [y] * len(it), "--", lw=0.5, color="black", alpha=0.3)    
  
# Remove the tick marks; they are unnecessary with the tick lines we just plotted.    
plt.tick_params(axis="both", which="both", bottom="off", top="off",    
                labelbottom="on", left="off", right="off", labelleft="on")    
  
plt.show()

# Studying different Learning Rates - No randomisation 
alp   = 0.2 