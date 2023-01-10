import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sb
import numpy as np
##https://towardsdatascience.com/heatmap-basics-with-pythons-seaborn-fb92ea280a6c
import sys

fileToLoad = sys.argv[1]
fileToSave = sys.argv[2]

df = pd.read_csv(fileToLoad, index_col=0, header = 0)
print(df)

#switch subplot size depending on heatmap size
fig, ax = plt.subplots(figsize=(10, 7))
#fig, ax = plt.subplots(figsize=(40, 30))

chart = sb.heatmap(df, cmap="Blues", annot=True,  fmt='g',  square=1, linewidth=1., cbar_kws={"shrink": .8, 'label': 'Number Correct\n n=500'}, annot_kws={"fontsize":18})
#for t in ax.texts: t.set_text(t.get_text() + " %")
cbar = ax.collections[0].colorbar
# cbar.set_ticks([.25, .5, .75, 1])
# cbar.set_ticklabels(['25%', '50%', '75%', '100%'])
cbar.ax.tick_params(labelsize=14)
# ticks
yticks = ['FE', 'FES\nStandard [2Fe-2S]', 'FES\nRieske [2Fe-2S]']
xticks =  ['FE', 'FES\nStandard [2Fe-2S]', 'FES\nRieske [2Fe-2S]']
plt.yticks(plt.yticks()[0], labels=yticks, rotation=0, fontsize = 14)
plt.xticks(plt.xticks()[0], labels=xticks, fontsize = 14)
chart.set_xticklabels(chart.get_xticklabels(), rotation=45, horizontalalignment='right')

title = "" #'Amino Classification'
plt.title(title, fontsize=36)
plt.xlabel('Predicted Values', fontsize = 14) # x-axis label with fontsize 15
plt.ylabel('True Values', fontsize = 14) # y-axis label with fontsize 15
plt.subplots_adjust(bottom=0.3)
plt.savefig(fileToSave)
