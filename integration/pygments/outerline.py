from pygments.lexer import RegexLexer, include
from pygments.token import *

__all__ = ['OuterlineLexer']

class OuterlineLexer(RegexLexer):
    name = 'Outerline'
    aliases = ['outerline']
    filenames = ['*.lne']
    mimetypes = ['text/x-outerline']

    tokens = {

        'root': [
            (r'\b(def|var|fun|use|num|true|false|when|else)\b', Keyword),

            (r'\(|,|;|\)', Operator),

            (r'#\(#', Comment.Multiline, 'multiline_comment'),
            (r'#.*?$', Comment.Single),
            
            (r'\{', String, 'interpolation'),

            (r'.', Name),
        ],

        'multiline_comment': [
            (r'#\(#', Comment.Multiline, '#push'),
            (r'#\)#', Comment.Multiline, '#pop'),
            (r'[^X]', Comment.Multiline), # TODO: Remove workaround
            (r'X', Comment.Multiline),
        ],

        'interpolation': [
            (r'\(', Operator, 'interpolation_escape'),
            (r'\}', String, '#pop'),
            (r'[^X]', String), # TODO: Remove workaround
            (r'X', String),
        ],

        'interpolation_escape': [
            (r'\)', Operator, '#pop'),
            include('root'),
        ],
    }


# vim:sw=4
