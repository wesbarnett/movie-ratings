import pandas as pd
import joblib

ratings = pd.read_csv('ratings.csv')
movies = pd.read_csv('movies.csv')
df = pd.merge(ratings, movies)
df.drop(['movieId', 'timestamp', 'genres'], axis=1, inplace=True)
df = df.pivot_table(values='rating', index='title', columns='userId')
df.sort_index(inplace=True)
joblib.dump(df, 'data.pkl')
