__author__ = 'anvar'

from django import template
import re

register = template.Library()


@register.filter(name='camel_case_parse')
def camel_case_parse(value):
    return re.sub(r'((?<=[a-z])[A-Z]|(?<!\A)[A-Z](?=[a-z]))', r' \1', value)
