import os
from datetime import datetime

def header(md,name):
    md.write('---\n')
    md.write('layout: default\n')
    md.write(f'title: {name}\n')
    md.write(f'thumbnail: images/{name}.png\n')
    md.write(f'permalink: /games/{name}.html\n')
    md.write(f"date: {datetime.today().strftime('%Y-%m-%d')}\n")
    md.write('---\n')
    md.write('\n')

def normal(f,md):
    md.write(f'## High Scores \n')
    md.write('{:.scoretext}\n')
    md.write('\n')
    md.write(f'| Name | Score | \n')
    md.write(f'| :---- | ----: | \n')  
    for i,line in enumerate(f):
        if line != '\n':
            md.write(f'| {line.strip()} ')
        else:
            md.write('| \n')
    md.write('| \n')
    md.write('{:.scoreText .table .td}')

def nba(f,md):
    print('what')

for file in os.listdir("C:\Visual Pinball\Hiscores\Text"):
    if file.endswith(".txt"):
        name = file.split('.')[0]
        md_path = f'C:\\Visual Pinball\\vmvpin.github.io\\_games\\{name}.md'
        if not os.path.exists(md_path):
            with open(md_path,'x'): pass
        md = open(md_path,'a')
        md.truncate(0)
        header(md,name)
        md.write(f'# {name} \n')
        md.write('{:.neontext}\n')
        md.write('\n')
        with open(os.path.abspath(f'C:\Visual Pinball\Hiscores\Text\{file}'), 'r') as f:
            if 'High Scores' in next(f):
                normal(f,md)
            else:
                nba(f,md)

