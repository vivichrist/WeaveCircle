let project = new Project('WeavingCircle');

project.addSources('Sources');

project.addShaders('Sources/Shaders/**');

resolve(project);
