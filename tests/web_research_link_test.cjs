const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');

// Exercise the actual embedded browser code without opening research websites.
const source = fs.readFileSync(path.join(__dirname, '../scripts/web_research_link.gd'), 'utf8');
const script = source.split('const INSTALL_SCRIPT := """')[1].split('"""')[0];
const handlers = new Map();
const opened = [];
let bounds = {left: 10, top: 20, width: 270, height: 480};
const canvas = {getBoundingClientRect: () => bounds};
const document = {
    body: {appendChild() {}},
    getElementById: () => canvas,
    addEventListener: (name, callback) => handlers.set(name, callback),
    removeEventListener: (name, callback) => {
        assert.equal(handlers.get(name), callback);
        handlers.delete(name);
    },
    createElement: () => ({
        click() { opened.push({url: this.href, target: this.target, rel: this.rel}); },
        remove() {}
    })
};
const window = {};
assert.equal(vm.runInNewContext(script, {window, document}), true);
const bridge = window.__talotsaResearchLink;
const data = {url: 'https://doi.org/example?x=1&y=2', rect: [104, 760, 332, 72], viewport: [540, 960]};
bridge.update(data);
function event(properties = {}) {
    return {target: canvas, button: 0, clientX: 145, clientY: 418,
        prevented: false, stopped: false,
        preventDefault() { this.prevented = true; },
        stopImmediatePropagation() { this.stopped = true; }, ...properties};
}
function touch(type, x = 145, y = 418, extra = {}) {
    const point = {identifier: 1, clientX: x, clientY: y};
    const e = event({touches: [point], changedTouches: [point], ...extra});
    handlers.get(type)(e);
    return e;
}
// Touch-down must not navigate; release opens exactly once and blocks Godot's input.
touch('touchstart');
assert.equal(opened.length, 0);
const release = touch('touchend');
assert.equal(opened.length, 1);
assert.ok(release.prevented && release.stopped);
assert.deepEqual(opened[0], {url: data.url, target: '_blank', rel: 'noopener noreferrer'});
touch('touchend');
assert.equal(opened.length, 1);
// Drags, cancelled gestures, and touches that began outside the button do not open.
touch('touchstart'); touch('touchmove', 180); touch('touchend', 180);
 touch('touchstart'); touch('touchend', 180);
touch('touchstart'); touch('touchcancel'); touch('touchend');
touch('touchstart', 0, 0); touch('touchend');
touch('touchstart', 145, 418, {touches: [{}, {}]}); touch('touchend');
assert.equal(opened.length, 1);
// A closed or changed folder invalidates the pending gesture.
touch('touchstart'); bridge.update(null); touch('touchend');
assert.equal(opened.length, 1);
bridge.update(data);
touch('touchstart'); bridge.update({...data, url: 'https://example.org/other'}); touch('touchend');
assert.equal(opened.length, 1);
bridge.update(data);
// Mouse and keyboard work, repeated keys and non-canvas controls do not navigate.
handlers.get('click')(event());
handlers.get('keydown')(event({key: 'Enter'}));
handlers.get('keydown')(event({key: ' ', repeat: true}));
handlers.get('click')(event({target: {}}));
assert.equal(opened.length, 3);
// Hit testing follows CSS canvas resizing and viewport changes (fullscreen).
bounds = {left: 30, top: 40, width: 540, height: 960};
handlers.get('click')(event({clientX: 300, clientY: 830}));
assert.equal(opened.length, 4);
bridge.update({...data, viewport: [1080, 1920]});
handlers.get('click')(event({clientX: 165, clientY: 438}));
assert.equal(opened.length, 5);
// A portrait game letterboxed in a wide canvas still uses the transformed button.
bridge.update({...data, rect: [374, 760, 332, 72], viewport: [1080, 960]});
handlers.get('click')(event({clientX: 300, clientY: 830}));
assert.equal(opened.length, 6);
handlers.get('click')(event({clientX: 150, clientY: 830}));
assert.equal(opened.length, 6);
bridge.update(null);
handlers.get('click')(event());
handlers.get('keydown')(event({key: 'Enter'}));
assert.equal(opened.length, 6);
bridge.dispose();
assert.equal(handlers.size, 0);
assert.equal(window.__talotsaResearchLink, undefined);
console.log('WEB RESEARCH LINK TEST PASSED');
