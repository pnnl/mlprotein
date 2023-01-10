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

import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm, ListedColormap
import seaborn as sns
import numpy as np

my_colors = ['#02ab2e', 'gold', 'orange', 'red', 'darkred']
my_cmap = ListedColormap(my_colors)
bounds = [0, 0.0001, .01, 0.05, 0.75, 1]
my_norm = BoundaryNorm(bounds, ncolors=len(my_colors))

grid_kws = {"height_ratios": (.9, .025), "hspace": .2}
fig, (ax, cbar_ax) = plt.subplots(nrows=2, figsize=(10,7), gridspec_kw=grid_kws)
sns.heatmap(df,
            annot=True,
            ax=ax,
            cmap=my_cmap,
            norm=my_norm,
            cbar_ax=cbar_ax,linewidth=1.,
            fmt=".0%",
            annot_kws={"fontsize":8},
            cbar_kws={"orientation": "horizontal", 'label': 'Percent Correct\n n=250'})


colorbar = ax.collections[0].colorbar
colorbar.set_ticks([(b0+b1)/2 for b0, b1 in zip(bounds[:-1], bounds[1:])])
colorbar.set_ticklabels(['0', '<1%', '<5%', '<75%', '100%'])

title = "" #'Amino Classification'
ax.set_title(title, fontsize=36)
ax.set_xlabel('Predicted Values', fontsize = 14) # x-axis label with fontsize 15
ax.set_ylabel('True Values', fontsize = 14, loc ='center') # y-axis label with fontsize 15
print(fileToSave)
plt.savefig(fileToSave)
