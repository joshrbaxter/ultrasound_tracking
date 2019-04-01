Code to convert Telemed ultrasound videos (TVD) to AVI -> MP4 for tracking code

tvd2avi.m -> sends commands to Telemed echowave thru command line to export TVDs as AVIs
tvd2avi_plusmp4.m -> a lot like tvd2avi.m but then saves the avi as mp4s - which are much smaller without losing much quality


NOTE: when collecting ultrasound data, we store the TVDs in a local folder that is not in a file syncing system. The TVD files can get really big, like 1GB big.
so, we save locally, convert to AVI and MP4 and then move the TVD to a cloud solution in a dedicated Ultrasound_TVD folder structure.
