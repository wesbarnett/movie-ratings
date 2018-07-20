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

from flask import render_template, flash, redirect, url_for, session
from app import app
from app.forms import SubmissionForm
from joblib import load, dump
import numpy as np
import pandas as pd
import random
from scipy.optimize import minimize
import shutil
import tempfile
import time
from threading import Thread

def cost(params, Y, n0, n1, num_features, lamb):
    X, Theta = np.split(params, [n0*num_features])
    X = X.reshape(n0, -1)
    Theta = Theta.reshape(n1, -1)
    return 0.5 * ((((np.matmul(Theta,X.T)).T - Y)**2).fillna(0).values.sum() + lamb*np.sum(Theta**2) + lamb*np.sum(X**2))

def gradient(params, Y, n0, n1, num_features, lamb):
    X, Theta = np.split(params, [n0*num_features])
    X = X.reshape(n0, -1)
    Theta = Theta.reshape(n1, -1)
    X_grad = (np.matmul(Theta.T, (np.matmul(Theta, X.T) - Y.T).fillna(0)) + lamb*X.T).T
    Theta_grad = (np.matmul(X.T, (np.matmul(Theta, X.T) - Y.T).fillna(0).T) + lamb*Theta.T).T
    return np.concatenate([X_grad.ravel(), Theta_grad.ravel()])

def run_collaborative_filtering(Y, num_features, l):
    
    # n0 = rows (movies)
    # n1 = cols (users)
    n0 = Y.shape[0]
    n1 = Y.shape[1]
    
    # Random initilization of parameters, stacked into one flat array
    Theta = np.random.randn(n0, num_features)
    X = np.random.randn(n1, num_features)
    x0 = np.hstack([X.ravel(), Theta.ravel()])
    
    # Subtract the mean for each movie
    Ynorm = Y.sub(Y.mean(axis=1), axis=0)
    
    minimize_result = minimize(cost, x0, method="L-BFGS-B", 
                           jac=gradient, args=(Ynorm, n0, n1, num_features, l), 
                           options={"maxiter": 100})
    
    X, Theta = np.split(minimize_result.x, [n0*num_features])
    X = X.reshape(n0, -1)
    Theta = Theta.reshape(n1, -1)
    
    # Create a DataFrame of the predictions; we have to add back the mean
    p = pd.DataFrame(np.matmul(X, Theta.T), index=Y.index, columns=Y.columns)
    p = p.add(Y.mean(axis=1), axis=0)
    return p

def delay_delete(delay, path):
    time.sleep(delay)
    shutil.rmtree(path)
    return

@app.route('/', methods=['GET', 'POST'])
@app.route('/index', methods=['GET', 'POST'])
def index():
    df = load('data.pkl')
    sorted_movies = df.count(axis=1).sort_values(ascending=False).index.tolist()[:100]
    random.shuffle(sorted_movies)
    
    form = SubmissionForm()
    movies = zip(sorted_movies[:20], form.radio)
    if form.validate_on_submit():

        tempfile.tempdir = 'app/static'
        tmpdir = tempfile.mkdtemp()
        session['tmpdir'] = tmpdir

        new_user = dict()
        for i, j in enumerate(sorted_movies[:20]):
            if form.radio[i].data == 'NA':
                new_user[j] = np.nan
            else:
                new_user[j] = float(form.radio[i].data)
        df['me'] = pd.Series(new_user)
        p = run_collaborative_filtering(df, 10, 10.0)
        predictions = p['me'].sort_values(ascending=False).index[:100]
        dump(predictions, tmpdir + '/predictions.pkl')
        return redirect('/results')
    return render_template('index.html', form=form,
            movies=movies)

@app.route('/results')
def results():
    tmpdir = session['tmpdir']
    predictions = load(tmpdir + '/predictions.pkl')
    del_thread = Thread(target=delay_delete, args=(600, tmpdir))
    del_thread.start()
    return render_template('results.html', predictions=predictions)
