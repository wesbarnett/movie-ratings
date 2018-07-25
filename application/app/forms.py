from flask_wtf import FlaskForm
from wtforms import SubmitField, RadioField, FieldList, IntegerField
from wtforms.validators import DataRequired, NumberRange

class SubmissionForm(FlaskForm):
    maxiter = IntegerField(validators=[DataRequired(),NumberRange(min=1)],default='100')
    radio = FieldList(RadioField(choices=[('NA','NA'),('1','1'),('2','2'),('3','3'),('4','4'),('5','5')],
        default='NA', validators=[DataRequired()]), min_entries=100)
    submit = SubmitField('Submit')
