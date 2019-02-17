import appscript
import shutil, os, sys
import itertools
from contextlib import closing
import lxml.etree as ET

filepath = "demo.key"  # sys.argv[1]
keynote = appscript.app('Keynote')
keynote_file = appscript.mactypes.File(filepath)

with closing(keynote.open(keynote_file)) as doc:
    notes = doc.slides.presenter_notes()
    skipped = doc.slides.skipped()
    notes = list(itertools.compress(notes, [not s for s in skipped]))

    texts = []
    hotwords = []
    for note in notes:
        lines = note.strip().splitlines()

        text = r"\n".join(lines[:-1])
        texts.append(text)

        assert lines[-1].startswith(':')
        hotword = lines[-1].lstrip(':').strip()
        hotwords.append(hotword)

resources = ET.Element("resources")
ET.SubElement(resources, "integer", name="nslides").text = str(len(notes))
texts_ = ET.SubElement(resources, "string-array", name="texts")
for text in texts:
    ET.SubElement(texts_, "item").text = text
hotwords_ = ET.SubElement(resources, "string-array", name="hotwords")
for hotword in hotwords:
    ET.SubElement(hotwords_, "item").text = hotword
tree = ET.ElementTree(resources)
tree.write("keynote.xml", pretty_print=True)
