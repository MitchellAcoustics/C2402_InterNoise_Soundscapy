# type: ignore
# flake8: noqa
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
import matplotlib.pyplot as plt
import pandas as pd
from pathlib import Path
import warnings

warnings.simplefilter("ignore")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
import soundscapy as sspy
```
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
sample_transform = {
    "RecordID": ["EX1", "EX2"],
    "pleasant": [4, 2],
    "vibrant": [4, 3],
    "eventful": [4, 5],
    "chaotic": [2, 5],
    "annoying": [1, 5],
    "monotonous": [3, 5],
    "uneventful": [3, 3],
    "calm": [4, 1],
}
sample_transform = pd.DataFrame().from_dict(sample_transform)
sample_transform = sample_transform.set_index("RecordID")
#
#
#
#| label: likert-radar
from soundscapy.plotting import likert
likert.paq_radar_plot(sample_transform)
```
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# Load data from the ISD
data = sspy.isd.load()

# Apply built-in data quality checks
data, excl_data = sspy.isd.validate(data, allow_paq_na=False)

# Calculate the ISO Coordinates
data = sspy.surveys.add_iso_coords(data)
#
#
#
#| echo: false
view_data = sspy.surveys.return_paqs(data, incl_ids = False, other_cols = ['ISOPleasant', 'ISOEventful'])
view_data.head(5)
```
#
#
#
#
#| echo: false
likert.paq_radar_plot(sample_transform)
```
#
#
#
#
#
#| code-fold: true
#| width: 125%
import seaborn as sns
sample_transform = sspy.surveys.rename_paqs(sample_transform)
sample_transform = sspy.surveys.add_iso_coords(sample_transform, overwrite=True)
colors = ["b", "r"]
palette = sns.color_palette(colors)
sspy.plotting.scatter_plot(sample_transform, hue="RecordID", palette=palette, diagonal_lines=True, legend="brief", s=100, figsize=(8,8))

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
sspy.plotting.density_plot(
  sspy.isd.select_location_ids(data, "CamdenTown"),
  title="Camden Town Soundscape Distribution",
  hue="LocationID",
  incl_scatter=True
)
```
#
#
#
#
#| code-line-numbers: '2,7'
sspy.plotting.density_plot(
  sspy.isd.select_location_ids(data, ("CamdenTown", "PancrasLock")),
  title = "Comparison between two soundscapes",
  hue = "LocationID",
  incl_scatter=True,
  incl_outline=True,
  simple_density=True,
)
```
#
#
#
#
#| code-line-numbers: "|1,6"
from soundscapy.plotting import Backend
import plotly.io as pio

sspy.plotting.scatter_plot(
  sspy.isd.select_location_ids(data, ("RegentsParkJapan")),
  backend = Backend.PLOTLY,
  title = "Regents Park Japanese Garden Soundscape",
)
```
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| label: database-load
# Load ISD data
isd_data = sspy.isd.load()

# Load SATP data
import soundscapy.databases.satp as satp
satp_data = satp.load_zenodo()

print(f"ISD shape: {isd_data.shape}")
print(f"SATP shape: {satp_data.shape}")

sspy.isd.soundscapy_describe(isd_data).head(5)
```
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| label: binaural-analysis
from soundscapy.audio.analysis_settings import MetricSettings
from soundscapy.audio import Binaural

b = Binaural.from_wav("data/CT101.wav")

laeq_settings = MetricSettings(
    run = True,
    statistics = (5, 50, 'avg', 'max'),
    label="LAeq",
)

b.pyacoustics_metric('LAeq', metric_settings=laeq_settings).round(2)
```
#
#
#
#
#
#
b.mosqito_metric('sharpness_din_perseg').round(2)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: false
__spec__ = None # Who fucking knows why: https://stackoverflow.com/questions/45720153/python-multiprocessing-error-attributeerror-module-main-has-no-attribute
#
#
#
#| eval: true
#| label: audio-analysis
#| code-line-numbers: "|1|5,6|8-12|14,15"
from soundscapy.audio import AudioAnalysis

wav_folder = Path("data")

# Initialize AudioAnalysis with default settings
analysis = AudioAnalysis()

# Analyse a folder of recordings
folder_results = analysis.analyze_folder(
    wav_folder, 
    calibration_file="data/Levels.json"
)

# Print results
folder_results.head()
```
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
