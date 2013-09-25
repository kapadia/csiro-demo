
onCube = (f) ->
  
  # Select the DOM element
  el = document.querySelector("div.volume[data-file='#{f}']")
  volume = new astro.Volumetric(el, 800)
  
  new astro.FITS("data/#{f}.fits", (f) ->
    cube = f.getDataUnit()
    
    width = cube.width
    height = cube.height
    depth = cube.depth
    
    # Allocate storage for cube
    pixels = new Float32Array(width * height * depth)
    frame = 0
    
    # Read data from file
    cube.getFrames(0, depth, (arr) ->
      pixels.set(arr, width * height * frame)
      
      frame += 1
      if frame is depth
        extent = cube.getExtent(pixels)
        gMinimum = minimum = extent[0]
        gMaximum = maximum = extent[1]
        
        volume.setExtent.apply(volume, extent)
        volume.setTexture(pixels, width, height, depth)
        volume.draw()
    )
  )

onHIPASS = (rows) ->
  
  el = $(".ruse")
  ruse = new astro.Ruse(el[0], 800, 400)
  
  unless ruse.gl?
    alert "Sadly this demo will be very boring since you don't have WebGL."
    return
  
  xAxisEl = document.querySelector('select[class="x-axis"]')
  yAxisEl = document.querySelector('select[class="y-axis"]')
  zAxisEl = document.querySelector('select[class="z-axis"]')
  
  xAxisEl.onchange = ->
    key1 = xAxisEl.value
    key2 = yAxisEl.value
    key3 = zAxisEl.value
    
    data = rows.map( (d) ->
      datum = {}
      datum[key1] = parseFloat(d[key1])
      datum[key2] = parseFloat(d[key2])
      datum[key3] = parseFloat(d[key3])
      
      return datum
    )
    ruse.plot(data)
  
  yAxisEl.onchange = ->
    xAxisEl.onchange()
  zAxisEl.onchange = ->
    xAxisEl.onchange()
  
  xAxisEl.removeAttribute('disabled')
  yAxisEl.removeAttribute('disabled')
  zAxisEl.removeAttribute('disabled')


# Set initial demo
currentDemo = "hipass"
onDemo =
  hipass: onHIPASS
  "eso149-g003.HI-cube": onCube
  "H005_abcde_luther_chop": onCube
  "H092_abcde_luther_chop": onCube


$(document).ready ->
  
  # Store actived demos
  demos = ["hipass"]
  
  # Start demo by requesting HIPASS data
  $.get("data/HIPASS.json")
    .done(onHIPASS);
  
  # User interactions
  $(".demo-link").on("click", (e) ->
    el = $(e.target)
    demo = el.data("demo")
    
    return if demo is currentDemo
    currentDemo = demo
    
    # Update nav state
    parent = $(".demo-link").parent()
    parent.removeClass("active")
    el.parent().addClass("active")
    
    # Show selected demo
    demosEl = $(".demo")
    demosEl.addClass("hide")
    $("div.demo[data-demo='#{demo}']").removeClass("hide")
    
    # Start demo
    unless demo in demos
      demos.push demo
      onDemo[demo](demo)
  )