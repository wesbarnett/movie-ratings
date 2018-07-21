from flask_wtf import FlaskForm
from wtforms import SubmitField, RadioField, FieldList, SelectField
from wtforms.validators import DataRequired

class SubmissionForm(FlaskForm):
    select = SelectField(choices=[('10','10'),('100','100'),('1000','1000')], validators = [DataRequired()], default='100')
    radio = FieldList(RadioField(choices=[('NA','NA'),('1','1'),('2','2'),('3','3'),('4','4'),('5','5')],
        default='NA', validators=[DataRequired()]), min_entries=100)
    submit = SubmitField('Submit')
