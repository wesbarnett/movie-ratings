#import sys
#sys.path.insert(0, '/srv/http/movie-ratings')

from app import app

if __name__ == '__main__':
    app.run(port=8080)
