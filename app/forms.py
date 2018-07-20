from flask_wtf import FlaskForm
from wtforms import SubmitField, RadioField, FieldList
from wtforms.validators import DataRequired

class SubmissionForm(FlaskForm):
    radio = FieldList(RadioField(choices=[('NA','NA'),('1','1'),('2','2'),('3','3'),('4','4'),('5','5')],
        default='NA', validators=[DataRequired()]), min_entries=100)
    submit = SubmitField('Submit')
