(function (global) {
  const VERTEX_SRC = `
attribute vec2 aPosition;
void main() {
  gl_Position = vec4(aPosition, 0.0, 1.0);
}
`;

  const FRAGMENT_HEADER = `
precision highp float;
uniform vec3 iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform int iFrame;
uniform vec4 iMouse;
uniform vec4 iDate;
`;

  const FRAGMENT_FOOTER = `
void main() {
  mainImage(gl_FragColor, gl_FragCoord.xy);
}
`;

  function compileShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      const log = gl.getShaderInfoLog(shader);
      gl.deleteShader(shader);
      const kind = type === gl.VERTEX_SHADER ? 'vertex' : 'fragment';
      throw new Error(`Erreur de compilation (${kind}) :\n${log || '(log vide)'}`);
    }
    return shader;
  }

  function linkProgram(gl, vertexShader, fragmentShader) {
    const program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      const log = gl.getProgramInfoLog(program);
      gl.deleteProgram(program);
      throw new Error(log || 'Erreur de link du programme');
    }
    return program;
  }

  class ShaderToyRuntime {
    constructor(canvas) {
      this.canvas = canvas;
      this.gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      if (!this.gl) {
        throw new Error('WebGL non disponible sur ce navigateur.');
      }

      this.program = null;
      this.rafId = null;
      this.playing = false;
      this.startTime = 0;
      this.lastTime = 0;
      this.elapsed = 0;
      this.frame = 0;
      this.mouse = [0, 0, 0, 0];

      this._setupGeometry();
      this._bindMouseEvents();
    }

    _setupGeometry() {
      const gl = this.gl;
      const buffer = gl.createBuffer();
      gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
      gl.bufferData(
        gl.ARRAY_BUFFER,
        new Float32Array([-1, -1, 3, -1, -1, 3]),
        gl.STATIC_DRAW
      );
      this.quadBuffer = buffer;
    }

    _bindMouseEvents() {
      const canvas = this.canvas;
      canvas.addEventListener('mousedown', (e) => {
        const rect = canvas.getBoundingClientRect();
        const x = ((e.clientX - rect.left) / rect.width) * canvas.width;
        const y = canvas.height - ((e.clientY - rect.top) / rect.height) * canvas.height;
        this.mouse = [x, y, x, y];
      });
      canvas.addEventListener('mousemove', (e) => {
        if (this.mouse[2] === 0 && this.mouse[3] === 0) return;
        const rect = canvas.getBoundingClientRect();
        const x = ((e.clientX - rect.left) / rect.width) * canvas.width;
        const y = canvas.height - ((e.clientY - rect.top) / rect.height) * canvas.height;
        this.mouse[0] = x;
        this.mouse[1] = y;
      });
      window.addEventListener('mouseup', () => {
        this.mouse[2] = 0;
        this.mouse[3] = 0;
      });
    }

    load(imageSource) {
      this.stop();

      const gl = this.gl;
      const fragmentSrc = FRAGMENT_HEADER + '\n' + imageSource + '\n' + FRAGMENT_FOOTER;

      const vertexShader = compileShader(gl, gl.VERTEX_SHADER, VERTEX_SRC);
      let fragmentShader;
      try {
        fragmentShader = compileShader(gl, gl.FRAGMENT_SHADER, fragmentSrc);
      } catch (err) {
        gl.deleteShader(vertexShader);
        throw err;
      }

      const program = linkProgram(gl, vertexShader, fragmentShader);
      gl.deleteShader(vertexShader);
      gl.deleteShader(fragmentShader);

      if (this.program) gl.deleteProgram(this.program);
      this.program = program;

      this.locations = {
        aPosition: gl.getAttribLocation(program, 'aPosition'),
        iResolution: gl.getUniformLocation(program, 'iResolution'),
        iTime: gl.getUniformLocation(program, 'iTime'),
        iTimeDelta: gl.getUniformLocation(program, 'iTimeDelta'),
        iFrame: gl.getUniformLocation(program, 'iFrame'),
        iMouse: gl.getUniformLocation(program, 'iMouse'),
        iDate: gl.getUniformLocation(program, 'iDate')
      };

      this.frame = 0;
      this.elapsed = 0;
      this.startTime = performance.now();
      this.lastTime = this.startTime;

      this._renderFrame();
      this.play();
    }

    play() {
      if (this.playing || !this.program) return;
      this.playing = true;
      this.lastTime = performance.now();
      this._loop();
    }

    pause() {
      this.playing = false;
      if (this.rafId !== null) {
        cancelAnimationFrame(this.rafId);
        this.rafId = null;
      }
    }

    stop() {
      this.pause();
      if (this.program) {
        this.gl.deleteProgram(this.program);
        this.program = null;
      }
    }

    reset() {
      this.frame = 0;
      this.elapsed = 0;
      this.startTime = performance.now();
      this.lastTime = this.startTime;
      this._renderFrame();
    }

    _loop() {
      if (!this.playing) return;
      const now = performance.now();
      const delta = (now - this.lastTime) / 1000;
      this.lastTime = now;
      this.elapsed += delta;
      this.frame += 1;
      this._renderFrame(delta);
      this.rafId = requestAnimationFrame(() => this._loop());
    }

    _renderFrame(delta) {
      const gl = this.gl;
      const canvas = this.canvas;
      if (!this.program) return;

      gl.viewport(0, 0, canvas.width, canvas.height);
      gl.useProgram(this.program);

      gl.bindBuffer(gl.ARRAY_BUFFER, this.quadBuffer);
      gl.enableVertexAttribArray(this.locations.aPosition);
      gl.vertexAttribPointer(this.locations.aPosition, 2, gl.FLOAT, false, 0, 0);

      const date = new Date();
      gl.uniform3f(this.locations.iResolution, canvas.width, canvas.height, 1.0);
      gl.uniform1f(this.locations.iTime, this.elapsed);
      gl.uniform1f(this.locations.iTimeDelta, delta || 0);
      gl.uniform1i(this.locations.iFrame, this.frame);
      gl.uniform4f(this.locations.iMouse, this.mouse[0], this.mouse[1], this.mouse[2], this.mouse[3]);
      gl.uniform4f(
        this.locations.iDate,
        date.getFullYear(),
        date.getMonth(),
        date.getDate(),
        date.getHours() * 3600 + date.getMinutes() * 60 + date.getSeconds()
      );

      gl.drawArrays(gl.TRIANGLES, 0, 3);
    }
  }

  global.ShaderToyRuntime = ShaderToyRuntime;
})(window);
