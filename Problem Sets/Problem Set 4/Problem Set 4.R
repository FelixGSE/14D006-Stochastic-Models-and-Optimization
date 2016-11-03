################################################################################
####################              Problemset 4              ####################
################################################################################

# Author:       Denitsa Panova, Zsuzsa Holler, Felix Gutmann, Thomas Vicente
# Programm:     Barcelona graduate school of economics - M.S. Data Science 
# Course:       15D012 - Advanced Computational Methods (Term 2)
# Exercise:     5 - LQR Computational Assignment
# Last update:  16.03.16

################################################################################
### Preamble
################################################################################

### Clear workspace
rm(list = ls())

### Set working directory

### Load package
if (!require("mvtnorm")) install.packages("mvtnorm"); library(mvtnorm)
if (!require("matrixcalc")) install.packages("matrixcalc"); library(matrixcalc)
if (!require("Matrix")) install.packages("Matrix"); library(Matrix)
if (!require("rlist")) install.packages("rlist"); library(rlist)

### Initialize auxilliary function

  # Shorten as.matrix command 
  AM <- function(x){ as.matrix(x) }
  
################################################################################
# Initialize functions to compute the states
################################################################################
  
compute.states <- function(  N  = 100, 
                             x0 = c(1,1), 
                             D  = diag(2),  
                             R  = diag(2) * c( 1, 2 ) , 
                             A  = matrix( sample(6,4,replace=TRUE), 2, 2),
                             B  = matrix( sample(6,4,replace=TRUE), 2, 2),
                             C  = c( 1, 1 ) )
{
# Set mean for disturbance
mu      <- c( 0 , 0 )
# Initialize matrices
x       <- matrix( NA , nrow = N , ncol = 2 )
x[1,]   <- x0 
Q       <- C %*% t(C)
K       <- list()
K[[N]]  <- Q
L       <- list()

# Compute K and L matrices
for (k in (N-1):1){

K[[k]] <-   t(A) %*% ( K[[(k+1)]] - K[[(k+1)]] %*% B %*% solve( t(B) %*% K[[(k+1)]] %*% B + R ) %*% t(B) %*% K[[(k+1)]] ) %*% A + Q
L[[k]] <- - solve( t(B) %*% K[[(k+1)]] %*% B + R) %*% t(B) %*% K[[(k+1)]] %*% A

}

# Compute states
for( k in 2:N ){
  
u.temp <- L[[(k - 1)]] %*% x[(k-1),]
w      <- rmvnorm( 1 , mean = mu , sigma = D ) 
x[k,]  <- A %*% AM( x[(k-1),] ) + B %*% u.temp + t(w)
  
}

# Return states
return(x)

}

# Compute states using the algebraic regati equation
rigati.states <- function(  N  = 100, 
                            x0 = c(1,1), 
                            D  = diag(2),  
                            R  = diag(2) * c( 1, 2 ) , 
                            A  = matrix( sample(6,4,replace=TRUE), 2, 2),
                            B  = matrix( sample(6,4,replace=TRUE), 2, 2),
                            C  = c( 1, 1 ) )
{
  # Set mean for disturbance
  mu      <- c( 0 , 0 )
  # Initialize matrices
  x       <- matrix( NA , nrow = N , ncol = 2 )
  x[1,]   <- x0 
  Q       <- C %*% t(C)
  K       <- Q

  # Compute K and L matrices
  
  K <- t(A) %*% ( K - K %*%B %*%solve( t(B) %*%K %*%B+R ) %*%t(B) %*%K)  %*% A + Q
  L <- - solve( t(B) %*% K %*% B + R ) %*%t(B) %*% K %*% A
  
  
  # Compute states
  for( k in 2:N ){
    
    u.temp <- L %*% x[(k-1),]
    w      <- rmvnorm( 1 , mean = mu , sigma = D ) 
    x[k,]  <- A %*% AM( x[(k-1),] ) + B %*% u.temp + t(w)
    
  }
  
  # Return states
  return(x)
  
}

################################################################################
### 1) Fix R and x0 / Use two different D ( D2 >> D1 )
################################################################################

A  = matrix( sample(4,4,replace=TRUE), 2, 2)
B  = matrix( sample(4,4,replace=TRUE), 2, 2)

D1 <- diag( 2 ) * c( 1 ,   1 )
D2 <- diag( 2 ) * c( 100 , 100 )

p01 <- compute.states( D = D1 , A = A, B = B )
p02 <- compute.states( D = D2 , A = A, B = B )

t <- 1:nrow(p01)

ymin <- min( c( p02[,1],p01[,2],  p02[,1],p02[,2] ))
ymax <- max( c(p02[,1],p01[,2],  p02[,1],p02[,2]  ))

plot( t , p01[,1] , type='l', col = 'blue' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
par( new = TRUE )
plot( t , p01[,2] , type='l', col = 'red' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
legend('bottomleft', c('State coordinate 1','State coordinate 2') , 
       lty=1, col=c('blue', 'red'), bty='n', cex=.75)

plot( t , p02[,1] , type='l', col = 'blue' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
par( new = TRUE )
plot( t , p02[,2] , type='l', col = 'red' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
legend('bottomleft', c('State coordinate 1','State coordinate 2') , 
       lty=1, col=c('blue', 'red'), bty='n', cex=.75)

################################################################################
### 2) Fix R and D / Use two different x0 ( x02 >> x01 )
################################################################################

x1 <- c( 1 , 1)
x2 <- c( 10, 10)

p03 <- compute.states( x0 = x1,A = A, B = B  )
p04 <- compute.states( x0 = x2,A = A, B = B  )

t2 <- 1:nrow(p02)

ymin <- min( c( p03[,1],p03[,2],  p04[,1],p04[,2] ))
ymax <- max( c( p03[,1],p03[,2],  p04[,1],p04[,2] ))


plot( t2 , p03[,1] , type='l', col = 'blue' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
par( new = TRUE )
plot( t2 , p03[,2] , type='l', col = 'red' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
legend('bottomleft', c('State coordinate 1','State coordinate 2') , 
       lty=1, col=c('blue', 'red'), bty='n', cex=.75)

#if( save == TRUE){ png( 'p01.png' ) }
plot( t2 , p04[,1] , type='l', col = 'blue' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
par( new = TRUE )
plot( t2 , p04[,2] , type='l', col = 'red' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
legend('bottomleft', c('State coordinate 1','State coordinate 2') , 
       lty=1, col=c('blue', 'red'), bty='n', cex=.75)

################################################################################
### 2) Fix x0 and D / Use two different R ( R02 >> R01 )
################################################################################

R1 <- diag(2) * c(0.5,0.2)
R2 <- diag(2) * c(100,100)

p05 <- compute.states( A = A, B = B, R = R1  )
p06 <- compute.states( A = A, B = B, R = R2  )

t3 <- 1:nrow(p05)

ymin <- min( c( p05[,1],p05[,2],  p06[,1],p06[,2] ))
ymax <- max( c( p05[,1],p05[,2],  p06[,1],p06[,2] ))


plot( t3 , p05[,1] , type='l', col = 'blue' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
par( new = TRUE )
plot( t3 , p05[,2] , type='l', col = 'red' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
legend('bottomleft', c('State coordinate 1','State coordinate 2') , 
       lty=1, col=c('blue', 'red'), bty='n', cex=.75)

#if( save == TRUE){ png( 'p01.png' ) }
plot( t3 , p06[,1] , type='l', col = 'blue' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
par( new = TRUE )
plot( t3 , p06[,2] , type='l', col = 'red' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
legend('bottomleft', c('State coordinate 1','State coordinate 2') , 
       lty=1, col=c('blue', 'red'), bty='n', cex=.75)


################################################################################
### 3) FFix R, x0, and D / system under optimal 
### control vs. steady-state control (given by the algebraic Riccati equation).
################################################################################

p07 <- rigati.states(  A = A, B = B )
p08 <- compute.states( A = A, B = B )


t4 <- 1:nrow(p05)

ymin <- min( c( p07[,1],p07[,2],  p08[,1],p08[,2] ))
ymax <- max( c( p07[,1],p07[,2],  p08[,1],p08[,2] ))

plot( t4 , p07[,1] , type='l', col = 'blue' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
par( new = TRUE )
plot( t4 , p07[,2] , type='l', col = 'red' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
legend('bottomleft', c('State coordinate 1','State coordinate 2') , 
       lty=1, col=c('blue', 'red'), bty='n', cex=.75)


plot( t4 , p08[,1] , type='l', col = 'blue' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
par( new = TRUE )
plot( t4 , p08[,2] , type='l', col = 'red' , ylim = c( ymin,ymax ), xlab = '', ylab = '')   
legend('bottomleft', c('State coordinate 1','State coordinate 2') , 
       lty=1, col=c('blue', 'red'), bty='n', cex=.75)


################################################################################

################################################################################