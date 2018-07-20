# Movie recommender

This started out as an exercise for writing a collaborative filtering
routine in Python, based off of what I learned in Andrew Ng's Machine
Learning course. From there I decided to update the data set and make
this into a Flask application. It's pretty slow right now, but it
works. In real world applications a user's ratings would be stored and
their recommendations would update periodically. Here I am asking for
a user's recommendations and then instantly giving them
recommendations, so the whole model has to be rebuilt.

The application is in production on my website at:

https://movies.barnett.science
