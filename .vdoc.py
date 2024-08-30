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
#| include: false
import matplotlib.pyplot as plt
from pathlib import Path
import time
import pandas as pd
from soundscapy.audio import AudioAnalysis
import warnings
warnings.filterwarnings("ignore")

__spec__ = None # solves a bug with multiprocessing

wav_dir = Path("data")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| echo: true
#| output: false
import soundscapy as sspy
df = sspy.isd.load()
#
#
#
#
#
#
#
#
#
#
#
#| output: false
df, excl_df = sspy.isd.validate(df)
df = sspy.surveys.add_iso_coords(df)
#
#
#
#
#
#
#
#
#
#
#
#| layout:
#|   - 100
# Setup side-by-side subplots
fig, axes = plt.subplots(1, 2, figsize=(11, 5))
# Plot the full soundscape distribution
sspy.density_plot(
  sspy.isd.select_location_ids(df, "CamdenTown"),
  title= "Camden Town soundscape distribution",
  hue="LocationID",
  ax=axes[0],
)
# Plot the simplified soundscape distributions, using the hue variable
sspy.density_plot(
  sspy.isd.select_location_ids(df, ("CamdenTown", "PancrasLock")),
  title="Comparison between two soundscapes",
  figsize=(5, 5),
  hue="LocationID",
  simple_density=True,
  ax=axes[1],
)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| include: false
#| output: false
def set_size(w,h, ax=None):
    """ w, h: width, height in inches """
    if not ax: ax=plt.gca()
    l = ax.figure.subplotpars.left
    r = ax.figure.subplotpars.right
    t = ax.figure.subplotpars.top
    b = ax.figure.subplotpars.bottom
    figw = float(w)/(r-l)
    figh = float(h)/(t-b)
    ax.figure.set_size_inches(figw, figh)
#
#
#
#| label: fig-binaural
#| fig-cap: Loading and viewing a binaural recording in Soundscapy.
from soundscapy import Binaural

# Load the binaural recording from a local wav
b = Binaural.from_wav(wav_dir.joinpath("CT101.wav"))
# Plot the binaural recording
ax = b.plot() 

# Resizing for the paper
ax.figure.set_size_inches(7, 3)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| output: false
#| include: false
b = Binaural(b.resample(48000), fs=48000)
#
#
#
#| label: tbl-psycho
#| tbl-cap: Direct output of psychoacoustic metrics calculated by Soundscapy for a single binaural recording.
metric = "loudness_zwtv"
stats = (5, 50, 'avg', 'max')
func_args = {'field_type': 'free'}
b.mosqito_metric(metric, statistics=stats, func_args=func_args)
#
#
#
#
#
#
#
#
#
analysis_settings = sspy.AnalysisSettings.default()
#
#
#
#
#
analysis_settings.get_metric_settings('MoSQITo', 'loudness_zwtv')
#
#
#
#
#
res_df = b.process_all_metrics(analysis_settings)
#
#
#
#
#
#
#
#
#
#| include: false
#| echo: false
from soundscapy import AudioAnalysis
from soundscapy.audio.parallel_processing import prep_multiindex_df, add_results
import json
levels = wav_dir.joinpath("Levels.json")
with open(levels) as f:
  levels = json.load(f)
df = prep_multiindex_df(levels, incl_metric=False)
#
#
#
#| include: false
#| output: false
ser_start = time.perf_counter()
#
#
#
#| label: serial-process
#| output: false
for wav in wav_dir.glob("*.wav"):
  recording = wav.stem
  decibel = tuple(levels[recording].values())
  b = Binaural.from_wav(wav, calibrate_to=decibel)
  ser_df = add_results(
    df, b.process_all_metrics(analysis_settings)
    )
#
#
#
#| output: false
#| include: false
ser_end = time.perf_counter()
#
#
#
#| include: false
#| output: false
par_start = time.perf_counter()
#
#
#
#| output: false
#| label: parallel-process
#| fig-cap: Batch processing of 10 recordings using Soundscapy's parallel processing function.
analysis = AudioAnalysis()
par_df = analysis.analyze_folder(wav_dir, calibration_file=wav_dir.joinpath('levels.json'), resample=48000)
#
#
#
#| output: false
#| include: false
par_end = time.perf_counter()
#
#
#
#| echo: false
#| output: asis
# print(f"Time taken for serial processing: {(ser_end - ser_start)/60:.2f} min")
# print(f"Time taken for parallel processing: {(par_end - par_start)/60:.2f} min")
# print(f"Speedup: {(ser_end - ser_start)/(par_end - par_start):.2f} times.")
from IPython.display import Markdown
ser_time = (ser_end - ser_start)
par_time = (par_end - par_start)
Markdown(f"Tested on a Macbook Pro M2 Max, processing 20 recordings (total of 10 minutes, 41 seconds of audio) in series took {ser_time/60:.1f} minutes, while processing the same 20 recordings in parallel took {par_time/60:.1f} minutes, a speed up of {ser_time / par_time:.1f} times.")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
