import numpy
from random import sample
from numpy import diag
import cPickle

class State(numpy.ndarray):
    symbols = {0: "_", 1: "X", 2: "O"}
    
    #3x3 array of zeros
    def __new__(subtype): 
        arr = numpy.zeros((3,3), dtype=numpy.int8)
        return arr.view(subtype)

    def __hash__(s): 
        flat = s.ravel() #array as vector
        code = 0
        for i in xrange(9): code += pow(3,i) * flat[i] #xrange(9) = seq(1,9) in R, pow(3,i) = 3^i
        return code

    def won(s, player): #all possibilities of winning
        x = s == player
        return numpy.hstack( (x.all(0), x.all(1), diag(x).all(), diag(x[:,::-1]).all()) ).any() #hstack = cbind in R

    def full(s):
        return (s != 0).all()

    def __str__(s): #fill the board with current state
        out = [""]
        for i in xrange(3):
            for j in xrange(3):
                out.append( s.symbols[ s[i,j] ] ) #we defined the possible symbols at the begining of the class
            out.append("\n")
        return str(" ").join(out)
        
class Learner:
    def __init__(s, player):
        s.valuefunc = dict()
        s.laststate_hash = None
        s.alpha = 0.9
        s.player = player
        s.gamehist = []
        s.traced = False
       
    def enum_actions(s, state):
        res = list()
        for i in xrange(3):
            for j in xrange(3):
                if state[i,j] == 0:
                    res.append( (i,j) )
        return res

    def value(s, state, action):
        "Assumption: Game has not been won by other player"
        state[action] = s.player
        hashval = hash(state)
        val = s.valuefunc.get( hashval )
        if val == None:
            if state.won(s.player): val = 1.0
            elif state.full(): val = 0.0
            else: val = 0.1
            s.valuefunc[hashval] = val
        state[action] = 0
        return val
        
    def next_action(s, state):
        valuemap = list()
        for action in s.enum_actions(state):
            val = s.value(state, action)
            valuemap.append( (val, action) )
        valuemap.sort(key=lambda x:x[0], reverse=True)
        maxval = valuemap[0][0]
        valuemap = filter(lambda x: x[0] >= maxval, valuemap)
        
        return sample(valuemap,1)[0]

    def next(s, state):
        if state.won(3-s.player):
            val = -1
        elif state.full():
            val = -0.1
        else:
            (val, action) = s.next_action(state)
            state[action] = s.player

        if state.won(1) or state.won(2) or state.full():
            s.traced = True
            
        #learning step
        if s.laststate_hash != None:
            s.valuefunc[s.laststate_hash] = (1.0-s.alpha) * s.valuefunc[s.laststate_hash] + s.alpha * val
        s.laststate_hash = hash(state)
        s.gamehist.append(s.laststate_hash)
        
    def reset(s):
        s.laststate_hash = None
        s.gamehist = []
        s.traced = False
                        
class Game:
    def __init__(s):
        s.learner = Learner(player=2)
        s.reset()
        s.sp = Selfplay(s.learner)
        
    def reset(s):
        s.state = State()
        s.learner.reset()
        print "** New Game **"
        print s.state

    def __call__(s, pi,pj):
        j = pi -1
        i = pj - 1
        if s.state[j,i] == 0:
            s.state[j,i] = 1
            s.learner.next(s.state)
        else:
            print "Invalid move"
        print s.state #,hash(s.state)

        if s.state.full() or s.state.won(1) or s.state.won(2):
            if s.state.won(1):
                print "You WIN"
            elif s.state.won(2):
                print "You LOOSE"
            else:
                print "DRAW Game"
            s.reset()

    def selfplay(s, n=1000):
        for i in xrange(n):
            s.sp.play()
        s.reset()

    def save(s):
        cPickle.dump(s.learner, open("learn.dat", "w"))

    def load(s):
        s.learner = cPickle.load( open("learn.dat") )
        s.sp = Selfplay(s.learner)
        s.reset()
             
class Selfplay:
    def __init__(s, learner = None):
        if learner == None:
            s.learner = Learner(player=2)
        else:
            s.learner = learner
        s.other = Learner(player=1)
        s.i = 0

    def reset(s):
        s.state = State()
        s.learner.reset()
        s.other.reset()

    def play(s):
        s.reset()
        while True:
            s.other.next(s.state)    
            s.learner.next(s.state)
            if s.state.full() or s.state.won(1) or s.state.won(2):
                s.i += 1
                if s.i % 100 == 0:
                    print s.state #hash(s.state)
                    
                if not s.other.traced:
                    s.other.next(s.state)
                break

if __name__ == "__main__":
    print "Tic tac toe - Place game piece using notation g(i,j), i being the row and j being the column"
    print "I.e. g(1,2) places a game piece in the first row, second column."
    print "Write g.selfplay(1000) to have the learner play against itself a 1000 times."
    g = Game()