###
    copied from http://29a.ch/2010/6/2/realtime-raytracing-in-javascript
        https://gist.github.com/422755

    all kudos to Jonas Wagner http://29a.ch/about

    ported to coffee-script with http://js2coffee.org/

    modified from dodo
###

{ abs, sqrt, floor, min } = Math

# helper

getDataFromImage = (img) ->
    canvas = document.createElement "canvas"
    canvas.width = img.width
    canvas.height = img.height
    ctx = canvas.getContext "2d"
    ctx.drawImage img, 0, 0
    ctx.getImageData 0, 0, img.width, img.height

# vector

class V3
    constructor: (@x, @y, @z) ->

    add: (v) ->
        new V3(@x + v.x, @y + v.y, @z + v.z)

    iadd: (v) ->
        @x += v.x
        @y += v.y
        @z += v.z

    sub: (v) ->
        new V3(@x - v.x, @y - v.y, @z - v.z)

    isub: (v) ->
        @x -= v.x
        @y -= v.y
        @z -= v.z

    mul: (v) ->
        new V3(@x * v.x, @y * v.y, @z * v.z)

    div: (v) ->
        new V3(@x / v.x, @y / v.y, @z / v.z)

    muls: (s) ->
        new V3(@x * s, @y * s, @z * s)

    imuls: (s) ->
        @x *= s
        @y *= s
        @z *= s

    divs: (s) ->
        @muls 1.0 / s

    dot: (v) ->
        @x * v.x + @y * v.y + @z * v.z

    normalize: ->
        s = 1.0 / sqrt(@x * @x + @y * @y + @z * @z)
        new V3(@x * s, @y * s, @z * s)

    magnitude: ->
        sqrt @x * @x + @y * @y + @z * @z

    magnitude2: ->
        @x * @x + @y * @y + @z * @z

    copy: ->
        new V3(@x, @y, @z)

# scene objects

class Camera
    constructor: (@origin, @topleft, @topright, @bottomleft) ->
        @offset =
            start: { x:0.0 , y:0.0 }
            stop:  { x:1.0 , y:1.0 }
        @update()

    update: ->
        @xd = @topright.sub(@topleft)
        @yd = @bottomleft.sub(@topleft)
        @d =
            x: @offset.stop.x - @offset.start.x
            y: @offset.stop.y - @offset.start.y

    getMagnitude: (x, y) ->
        p = @topleft.add(@xd.muls( x*@d.x + @offset.start.x ))
        p.iadd @yd.muls( y*@d.y + @offset.start.y )
        p.iadd @yd.muls(y)
        p.sub(@origin).magnitude()

    getRay: (x, y) ->
        p = @topleft.add(@xd.muls( x*@d.x + @offset.start.x ))
        p.iadd @yd.muls( y*@d.y + @offset.start.y )
        p.isub @origin
        origin: @origin
        direction: p.normalize()

class Sphere
    constructor: (@center, @radius) ->
        @radius2 = radius * radius

    intersect: (ray) ->
        distance = ray.origin.sub(@center)
        b = distance.dot(ray.direction)
        c = b * b - distance.magnitude2() + @radius2
        (if c > 0.0 then -b - sqrt(c) else -1.0)

    getNormal: (point) ->
        point.sub(@center).normalize()

class Body
    constructor: (@shape, @material) ->

class CubeMap
    constructor: (img) ->
        img = getDataFromImage(img)
        s = @size = img.width / 3
        @width = img.width
        @left = s * img.width
        @front = (s + s * img.width)
        @right = (s * 2 + s * img.width)
        @back = (s + s * 3 * img.width)
        @up = s
        @down = (s + s * 2 * img.width)
        @colors = []
        i = 0
        data = img.data
        i = 0

        while i < data.length
            color = new V3(data[i++], data[i++], data[i++])
            color.imuls 0.00390625
            color.imuls 2.5  if color.x * color.y * color.z > 0.95
            @colors.push color
            i++

    sample: (ray) ->
        d = ray.direction
        ax = abs(d.x)
        ay = abs(d.y)
        az = abs(d.z)
        s = @size
        u = 0.0
        v = 0.0

        if ax >= ay and ax >= az
            if d.x > 0.0
                u = 1.0 - (d.z / d.x + 1.0) * 0.5
                v = (d.y / d.x + 1.0) * 0.5
                o = @right
            else
                u = 1.0 - (d.z / d.x + 1.0) * 0.5
                v = 1.0 - (d.y / d.x + 1.0) * 0.5
                o = @left
        else if ay >= ax and ay >= az
            if d.y <= 0.0
                u = (d.x / d.y + 1.0) * 0.5
                v = 1.0 - (d.z / d.y + 1.0) * 0.5
                o = @up
            else
                u = (d.x / d.y + 1.0) * 0.5
                v = 1.0 - (d.z / d.y + 1.0) * 0.5
                o = @down
        else
            if d.z > 0.0
                u = (d.x / d.z + 1.0) * 0.5
                v = (d.y / d.z + 1.0) * 0.5
                o = @front
            else
                u = (d.x / d.z + 1.0) * 0.5
                v = (d.y / d.z + 1.0) * 0.5
                o = @back
        o += floor(u * s) + floor(v * s) * @width
        @colors[o]

# raytracer

class Renderer
    constructor: (@scene, @ctx) ->
        @img = @ctx.getImageData(0, 0, @scene.output.width, @scene.output.height)
        @data = @img.data

    render: ->
        w = @img.width
        h = @img.height
        i = 0
        data = @data
        y = 0.0
        ystep = 1.0 / h

        while y < 0.99999
            x = 0
            xstep = 1.0 / w

            while x < 0.99999
                ray = @scene.camera.getRay(x, y)
                color = @trace(ray, 0)
                data[i++] = min(floor(color.x * 256), 255)
                data[i++] = min(floor(color.y * 256), 255)
                data[i++] = min(floor(color.z * 256), 255)
                data[i++] = 255
                x += xstep
            y += ystep
        @ctx.putImageData @img, 0, 0

    trace: (ray, n) ->
        mint = Infinity
        hit = null
        i = 0

        while i < @scene.objects.length
            o = @scene.objects[i]
            t = o.shape.intersect(ray)
            if t > 0.0 and t < mint
                mint = t
                hit = o
            i++
        if hit
            origin = ray.origin.add(ray.direction.muls(mint))
            normal = hit.shape.getNormal(origin)
            direction = hit.material.bounce(ray, normal)
            if direction.dot(ray.direction) > 0.0
                n -= 1
                origin = ray.origin.add(ray.direction.muls(1.000001 * mint))
            newray = { origin, direction }

            return @scene.sky.sample(ray)  if n > 1
            return @trace(newray, n + 1).mul(hit.material.color)
        @scene.sky.sample ray

# materials

class Chrome
    constructor: (@color) ->

    bounce: (ray, normal) ->
        theta1 = abs(ray.direction.dot(normal))
        ray.direction.add normal.muls(theta1 * 2.0)

class Glass
    constructor: (@color, @ior) ->

    bounce: (ray, normal) ->
        theta1 = abs(ray.direction.dot(normal))
        if theta1 >= 0.0
            internalIndex = @ior
            externalIndex = 1.0
        else
            internalIndex = 1.0
            externalIndex = @ior
        eta = externalIndex / internalIndex
        theta2 = sqrt(1.0 - (eta * eta) * (1.0 - (theta1 * theta1)))
        ray.direction.muls(eta).sub normal.muls(theta2 - eta * theta1)

# controller

class Animator
    constructor: ->
        @t = 0.0
        @points = []

    add: (point, speed) ->
        @points.push
            point: point
            radius: point.magnitude()
            alpha: Math.atan2(1, 0) - Math.atan2(point.x, point.z)
            speed: speed

    tick: (td) ->
        @t += td
        i = 0

        while i < @points.length
            p = @points[i]
            p.point.x = Math.cos(p.alpha + @t * p.speed) * p.radius
            p.point.z = Math.sin(p.alpha + @t * p.speed) * p.radius
            i++

class FPSCounter extends Backbone.EventEmitter
    constructor: (@ctx) ->
        @t = new Date().getTime() / 1000.0
        @n = 0
        @value = 0.0

    draw: ->
        @n++
        if @n is 50
            @n = 0
            t = new Date().getTime() / 1000.0
            @value = Math.round(50.0 / (t - @t) * 100) / 100
            @t = t
        #@ctx.fillText @value, 1, 10
        @trigger 'draw', @value

# exports

class exports.Engine extends Backbone.EventEmitter

    constructor: ({@canvas, skysrc, @quality, @motionblur}) ->
        @ctx = @canvas.getContext "2d"
        @fps = new FPSCounter(@ctx)
        @quality ?= 0.2
        @motionblur ?= 0.05
        @img = document.createElement "img"
        @img.onload = @main
        @img.src = skysrc
        @running = false

    main: =>
        camera = new Camera(
            new V3(0.0, 0.0, -8.4),
            new V3(-1.3, -1.0, -7.0),
            new V3(1.3, -1.0, -7.0),
            new V3(-1.3, 1.0, -7.0)
        )
        objects = [
            new Body(new Sphere(new V3(0.0, 0.0, 3.0), 0.5), new Glass(new V3(1.0, 1.0, 1.0), 1.5))
            new Body(new Sphere(new V3(0.0, 0.0, 4.5), 0.7), new Chrome(new V3(0.5, 0.5, 0.8)))
            new Body(new Sphere(new V3(0.0, 0.0, 6.0), 0.6), new Chrome(new V3(0.5, 0.8, 0.5)))
            new Body(new Sphere(new V3(0.0, 0.0, 7.5), 0.5), new Chrome(new V3(0.8, 0.5, 0.5)))
        ]
        @animator = new Animator @scene =
            sky: new CubeMap(@img)
            objects: objects
            camera: camera
            output:
                width: @canvas.width * @quality
                height: @canvas.height * @quality

        @animator.add @scene.camera.origin, 0.15
        @animator.add @scene.camera.topleft, 0.15
        @animator.add @scene.camera.topright, 0.15
        @animator.add @scene.camera.bottomleft, 0.15
        i = 0

        while i < @scene.objects.length
            speed = 2 / (i + 1)
            speed = -speed  if i & 1
            @animator.add @scene.objects[i].shape.center, speed
            i++

        @buffer = document.createElement("canvas")
        @buffer.width = @scene.output.width
        @buffer.height = @scene.output.height
        @renderer = new Renderer(@scene, @buffer.getContext("2d"))

        @ctx.globalAlpha = 1.00 - @motionblur
        @tick forced:yes

    tick: ({forced} = {}) =>
        return unless @running or forced
        @animator.tick 0.03
        @scene.camera.update()
        @renderer.render()
        @ctx.drawImage @buffer, 0, 0, @canvas.width, @canvas.height
        @trigger 'tick', this
        @fps.draw()

