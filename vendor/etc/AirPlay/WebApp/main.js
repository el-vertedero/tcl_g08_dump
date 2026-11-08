//Set the following Node Env variable to enable AV1, VP9 and HEVC support
process.env.UseCoreMediaParsersOverwrite = "1";
require("./compatibility.bundle.js");
require("./airplay.bundle.js");
