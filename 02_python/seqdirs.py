#!/usr/bin/envpython3

import sys
import os
import subprocess as sp
# import datetime
# import json
# from pprint import pprint
import utils

ffmpeg_inString = [
    '/usr/bin/env', 'ffmpeg',
    '-hide_banner',
    '-loglevel', 'error',
    '-thread_queue_size', '512',
    '-r', '25',
    '-pattern_type', 'glob',
]

ff_AudioMasterArgs = [
    '-c:a', 'pcm_s24le',
]

ff_AudioRefArgs = [
    '-c:a', 'aac',
    '-b:a', '256k'
]

ff_VidMasterArgs = [
    '-c:v', 'prores_ks',
    '-b:v', '40000k',
    '-profile:v', '4444',
    '-pix_fmt', 'yuv444p10le',
    '-f', 'mov'
]

ff_VidRefArgs = [
    '-c:v', 'libx264',
    '-minrate', '12000k',
    '-maxrate', '20000k',
    '-bufsize', '20000k',
    '-pix_fmt', 'yuv420p',
    '-vf', 'scale=trunc(iw/2)*2:trunc(ih/2)*2',
    '-f', 'mp4'
]

ff_AudioInString = [
    '-map', '0:0',
    '-map', '1:0',
    '-channel_layout', 'stereo',
]


def getAudioFileFromFilelist(filelist):
    """Search for audiofile.

    Searches for audio files in filelist,
    returns filename if it ends in a known audio extention
    """
    for audioFile in filelist:
        audioRoot, audioExt = os.path.splitext(audioFile)
        if audioExt in ['.wav', '.aiff', '.aif']:
            return audioFile
# end getAudioFileFromFilelist


def addAudioToFFCommand(audiofilepath, ffmpegcommand):
    """Add audio input and ffmpeg arguments to ffmpeg Command."""
    ffmpegcommand.extend(['-i', audiofilepath])
    ffmpegcommand.extend(ff_AudioInString)
# end addAudioToFFCommand


if __name__ == "__main__":
    # Specify all inputs and outputs
    inFolder = sys.argv[1]
    inFormat = sys.argv[2]
    outVar = sys.argv[3]
    outFolder = sys.argv[4]

    if outVar.lower() == 'master':
        outFormat = 'mov'
    elif outVar.lower() == 'ref':
        outFormat = 'mp4'
    # for audioFile in audioList:
    #     ff_Command.extend(['-i', "audioInput"])
    #     ff_Command.extend(ff_AudioArgs)
    #     if outformat.lower() == 'master':
    #         ff_Command.extend(ff_AudioMasterArgs)
    #     elif outformat.lower() == 'ref':
    #         ff_Command.extend(ff_AudioRefArgs)

    inSequence = []
    for dirpath, dirnames, filenames in os.walk(inFolder):
        filteredDirList = utils.filterHiddenFiles(dirnames)
        filteredFileList = utils.filterHiddenFiles(filenames)
        for filename in filteredFileList:
            if filename.endswith(inFormat):
                inSequence.append(filename)

        if len(inSequence) >= 25:
            ff_Command = []
            print('Found image sequence at', dirpath)
            videoInput = os.path.join(dirpath, "*.{}".format(inFormat))
            ff_Command.extend(ffmpeg_inString)
            ff_Command.extend(['-y', '-i', videoInput])

            audioFileName = getAudioFileFromFilelist(filelist=filteredFileList)
            print(audioFileName)
            if audioFileName is not None:
                print('Found audio file, relaying with', audioFileName)
                audioFullPath = os.path.join(dirpath, audioFileName)
                addAudioToFFCommand(
                    audiofilepath=audioFullPath,
                    ffmpegcommand=ff_Command
                )

            if outVar.lower() == 'master':
                ff_Command.extend(ff_VidMasterArgs)
                ff_Command.extend(ff_AudioMasterArgs)
            elif outVar.lower() == 'ref':
                ff_Command.extend(ff_VidRefArgs)
                ff_Command.extend(ff_AudioRefArgs)

            inBase = os.path.basename(
                os.path.abspath(inFolder)
                )
    # pathBase = os.path.basename(
    #     os.path.dirname(dirpath)
    #     )
            videoBase = os.path.basename(
                os.path.abspath(dirpath)
                )

            outDir = os.path.join(outFolder, inBase, videoBase)

            outName = os.path.join(
                outDir,
                "{}.{}".format(
                    os.path.splitext(videoBase)[0],
                    outFormat
                )
            )
            if not os.path.isdir(outDir):
                    os.makedirs(outDir)
            ff_Command.extend(['-aspect:0', '16:9', '-r', '25', outName])
    # # print("__________________")
    # # print(" ")
    # # print("pathBase is", pathBase)
    # # print(" ")
    # # print("inBase is", inBase)
    # # print(" ")
    # # print("videoBase is", videoBase)
    # # print(" ")
    # # print("++++++++++++++++++")
    # # print(" ")
    # # print("outDir is", outDir)
    # # print(" ")
    # # print("outName is", outName)
    # # print(" ")
    # # print("__________________")
    #
            print("Creating", os.path.basename(outName))
            if not os.path.isfile(outName):
                sp.run(ff_Command)
            print(" ".join(ff_Command))
            print("Export done. Moving to next folder.")
            print(" ")
            # elif len(inSequence) == 0:
#                 print("No", inFormat, "sequence found in", dirpath)
#                 print("Moving to next folder.")
        inSequence = []
