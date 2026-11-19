{
  ...
}:
{
  config = {
    services.easyeffects = {
      enable = true;

      presets = {
        # Thank you to @stirlingsilver for the amazing EasyEffects profile.
        #
        # see: https://github.com/stirlingsilver/fw13pro-customizations/blob/main/FW13SpeakersV2-Loudness.json
        framework-13-pro = {
           output = {
            blocklist = [ ];
            "compressor#0" = {
              attack = 5;
              boost-amount = 6;
              boost-threshold = -72;
              bypass = false;
              dry = -80.01;
              hpf-frequency = 10;
              hpf-mode = "Off";
              input-gain = 15;
              input-to-link = -80.01;
              input-to-sidechain = -80.01;
              knee = -6;
              link-to-input = -80.01;
              link-to-sidechain = -80.01;
              lpf-frequency = 20000;
              lpf-mode = "Off";
              makeup = 0;
              mode = "Downward";
              output-gain = 0;
              ratio = 4;
              release = 100;
              release-threshold = -80.01;
              sidechain = {
                lookahead = 0;
                mode = "Peak";
                preamp = 0;
                reactivity = 10;
                source = "Middle";
                stereo-split-source = "Left/Right";
                type = "Feed-forward";
              };
              sidechain-to-input = -80.01;
              sidechain-to-link = -80.01;
              stereo-split = false;
              threshold = -6;
              wet = 0;
            };
            "equalizer#0" = {
              balance = -0.1;
              bypass = false;
              decramp = "Off";
              input-gain = -19;
              left = {
                band0 = {
                  frequency = 29.9526;
                  gain = -15.44;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band1 = {
                  frequency = 59.7633;
                  gain = -4.02;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band2 = {
                  frequency = 119.244;
                  gain = 11.23;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band3 = {
                  frequency = 237.922;
                  gain = -5.33;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band4 = {
                  frequency = 474.717;
                  gain = -13.7;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band5 = {
                  frequency = 947.185;
                  gain = -9.07;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band6 = {
                  frequency = 1889.88;
                  gain = -17.6;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band7 = {
                  frequency = 3770.81;
                  gain = -18.44;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band8 = {
                  frequency = 7523.76;
                  gain = -1.54;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band9 = {
                  frequency = 15011.9;
                  gain = -3.81;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
              };
              mode = "IIR";
              num-bands = 10;
              output-gain = 11;
              pitch-left = 0;
              pitch-right = 0;
              right = {
                band0 = {
                  frequency = 29.9526;
                  gain = -15.44;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band1 = {
                  frequency = 59.7633;
                  gain = -4.02;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band2 = {
                  frequency = 119.244;
                  gain = 11.23;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band3 = {
                  frequency = 237.922;
                  gain = -5.33;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band4 = {
                  frequency = 474.717;
                  gain = -13.7;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band5 = {
                  frequency = 947.185;
                  gain = -9.07;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band6 = {
                  frequency = 1889.88;
                  gain = -17.6;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band7 = {
                  frequency = 3770.81;
                  gain = -18.44;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band8 = {
                  frequency = 7523.76;
                  gain = -1.54;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
                band9 = {
                  frequency = 15011.9;
                  gain = -3.81;
                  mode = "APO (DR)";
                  mute = false;
                  q = 1.50476;
                  slope = "x1";
                  solo = false;
                  type = "Bell";
                  width = 4;
                };
              };
              split-channels = false;
            };
            "limiter#0" = {
              alr = false;
              alr-attack = 5;
              alr-knee = 0;
              alr-knee-smooth = -5;
              alr-release = 50;
              attack = 5;
              bypass = false;
              dithering = "None";
              gain-boost = true;
              input-gain = 0;
              input-to-link = -80.01;
              input-to-sidechain = -80.01;
              link-to-input = -80.01;
              link-to-sidechain = -80.01;
              lookahead = 5;
              mode = "Line Wide";
              output-gain = 0;
              oversampling = "None";
              release = 5;
              sidechain-preamp = 0;
              sidechain-to-input = -80.01;
              sidechain-to-link = -80.01;
              sidechain-type = "Internal";
              stereo-link = 100;
              threshold = 0;
            };
            "loudness#0" = {
              bypass = false;
              clipping = false;
              clipping-range = 6;
              fft = "256";
              iir-approximation = "Normal";
              input-gain = 0;
              mode = "FFT";
              output-gain = 0;
              std = "ISO226-2023";
              volume = 7;
            };
            plugins_order = [
              "equalizer#0"
              "loudness#0"
              "compressor#0"
              "limiter#0"
            ];
          };
        };
      };
    };
  };
}