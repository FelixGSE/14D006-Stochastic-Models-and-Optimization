################################################################################
#################   Problemset 2 - Traveling Salesman Problem    ###############
################################################################################

# Author:       Denitsa Panova, Zsuzsa Holler, Felix Gutmann, Thomas Vicente
# Programm:     Barcelona graduate school of economics - M.S. Data Science 
# Course:       14D006 Stochastic Models and Optimization
# Last update:  02.03.2016

# Content:      This script creates a function to perform a greedy search for
#               a mininum weight Hamiltonian Cycle in a graph. Since the given 
#               graph is complete greedy search is easy to implement and 
#               the runtime is reasonable given the size of the data set. 
#               However, the obtained  solution is not garantueed to be to be the 
#               global optimum. 

# Dependencies: The implementation solely uses the the R base package 

# Results:      1) Optimal solution: 79114 ( Source website )
#               2) Greedy solution:  96514 ( Implementation )
#               3) Greedy benchmark: 100615 / Computed by Wolfram - 
#                  Mathematica: FindShortestTour[ ??? , Method -> "Greedy"] 

################################################################################
# Preamble
################################################################################

### Clear workspace
rm( list = ls () )

### Set working directory
setwd('/Users/felix/Dropbox/GSE/Term2/SMO/Problemset2')

### Load data
data <- read.table('uy734.tsp.txt')[,2:3]

################################################################################
# Intialize functions
################################################################################

# Function for Greedy Hamiltonian cycle search in complete weighted graphs. 
mole <- function( adjacencyMatrix,  source ){
  # Compute number of vertices and initialize tracking variables
  N          <- nrow( adjacencyMatrix ) 
  sequence   <- c( source )
  pathWeight <- 0 
  # Run greedy search starting at the source node
  for( i in 1:N  ){
    # In the final step go back to source node
    if( i == N ){ 
      temp       <- sequence[i]
      weight     <- adjacencyMatrix[ temp , ][ source ]
      pathWeight <- pathWeight + weight
    # Still unvisted nodes in the adjacency outlist of each node
    } else { 
      temp    <- sequence[i]
      outlist <- adjacencyMatrix[ temp , ]
      pos     <- setdiff( order( outlist ) , sequence )[ 1 ]
      weight  <- outlist[ pos ]
      pathWeight <- pathWeight + weight
      sequence   <- c( sequence , pos ) 
    }
  }  
  # Design final and return output  
  output <- list( path = sequence , distance = pathWeight  )
  return( output )
}


greedySalesMan <- function( coordinates ){ 
  
  # Compute distance matrix as weighted adjacency matrix
  adjacencyMatrix  <- as.matrix( dist( coordinates , 
                                       method = 'euclidean', 
                                       diag   = TRUE, 
                                       upper  = TRUE 
  ))
  
  # Compute number of vertices and initialize global storage objects
  N         <- nrow( adjacencyMatrix )
  paths     <- matrix( NA , nrow = N , ncol = N ) 
  distances <- rep( NA, N ) 
  
  # Run greedy search for each node in the graph - start at j = 1
  for( j in 1:N ){
    
    # Intialize storage local objects
    source     <- j 
    sequence   <- c( source )
    pathWeight <- 0 
    
    # Find greedy cycle for node j
    for( i in 1:N  ){
      # If final step reached go back to source node
      if( i == N ){ 
        temp       <- sequence[i]
        weight     <- adjacencyMatrix[ temp , ][ source ]
        pathWeight <- pathWeight + weight
        # Choose next minimum node if still unvisted nodes in the outlist of prev. node
      } else { 
        # Get current node and its outlist 
        temp       <- sequence[i]
        outlist    <- adjacencyMatrix[ temp , ]
        # Compute minimum weight for remaining nodes
        pos        <- setdiff( order( outlist ) , sequence )[ 1 ]
        weight     <- outlist[ pos ]
        # Update local storage objects
        pathWeight <- pathWeight + weight
        sequence   <- c( sequence , pos ) 
      }
    }  
    # Update globol storage ubject for node j
    paths[j , ]  <- sequence
    distances[j] <- pathWeight
  }
  # Find minum and return final output  
  argMin  <- which( distances == min( distances ) )
  optDist <- distances[ argMin ]
  optPath <- paths[ argMin , ]
  greedySolution <- list( minWeightPath = optPath, minDistance = optDist )
  return( greedySolution )
}


################################################################################
# Results 
################################################################################

# Compute runtime and results
start.time <- proc.time()
tsp        <- greedySalesMan(data) 
runtime    <- proc.time() - start.time

# Temp data set for line plot
d02 <- data[ tsp$minWeightPath , ]

# Plot cycle  
plot( data[,1] , data[,2] , 
      axes = FALSE , 
      xlab = '',
      ylab = '',
      cex  = .3,
      pch  = 19
     )
par( new = TRUE )
lines( d02[,1] , d02[,2] , 
       col = 'red'
     )
title('Greedy minum weight cycle')

################################################################################

################################################################################