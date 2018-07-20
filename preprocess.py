# Copyright 2018 Wes Barnett

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import pandas as pd
import joblib

ratings = pd.read_csv('ratings.csv')
movies = pd.read_csv('movies.csv')
df = pd.merge(ratings, movies)
df.drop(['movieId', 'timestamp', 'genres'], axis=1, inplace=True)
df = df.pivot_table(values='rating', index='title', columns='userId')
df.sort_index(inplace=True)
joblib.dump(df, 'data.gz')
