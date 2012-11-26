class BasePlot

    constructor: ->
        @_width = 720
        @_height = 680

    draw: (selection) =>
        me = @
        selection.each( (d, i) -> me._draw(this, d, i) )

    _draw: (elem, data, i) ->
        throw "Not implemented"

    width: (value) ->
        if not arguments.length
            return @_width
        @_width = value
        @

    height: (value) ->
        if not arguments.length
            return @_height
        @_height = value
        @

class window.Plot extends BasePlot

    _draw: (elem, data) ->

        debugger

        # Compute x- and y-domains
        for d in data
            data.timestamp = new Date(data.timestamp)
        x_domain = d3.extent(data, (d) -> d.timestamp)
        y_domain = d3.extent(data, (d) -> d.comments)

        # Off-the-shelf viewport
        {plot, x, y} = configure_viewport(elem, x_domain, y_domain, true)

        # Add data points
        points = plot.selectAll('circle').data(data)

        points.enter()
            .attr('cx', (d) -> x(d.x))
            .attr('cy', (d) -> y(d.y))


configure_viewport = (elem, x_domain, y_domain, xtime=false) ->
    # Viewport configuration boilerplate
    # Returns:
    #     plot: the plot element (a d3 selection)
    #     x: d3.scale object for x dimension
    #     y: d3.scale object for y dimension

    container = d3.select(elem)

    # Set viewport dimensions
    margins = {top: 10, right: 20, bottom: 30, left: 60}
    svg_dims =
        width: container.width()
        height: container.height()
    plot_dims = {
        width: svg_dims.width - margins.left - margins.right
        height: svg_dims.height - margins.top - margins.bottom
    }

    # Create the plot element
    svg = container.append('svg')
        .attr('width', svg_dims.width)
        .attr('height', svg_dims.height)
    plot = svg.append('g')
        .attr('width', plot_dims.width)
        .attr('height', plot_dims.height)

    # Create x- and y- scales
    if xtime
        xscale = d3.time.scale()
            .domain(x_domain)
            .range([0, plot_dims.width])
    else
        xscale = d3.scale.linear()
            .domain(x_domain)
            .range([0, plot_dims.width])
    yscale = d3.scale.linear()
        .domain(y_domain)
        .range([plot_dims.height, 0])

    # x- and y- axes
    xaxis = d3.svg.axis()
        .scale(xscale)
    yaxis = d3.svg.axis()
        .scale(yscale)
        .orient('left')

    plot.append('g')
        .attr('class', 'x axis')
        .attr('transform', "translate(0, #{plot_dims.height})")
        .call(xaxis)

    plot.append('g')
        .attr('class', 'y axis')
        .attr('transform', "translate(0, #{plot_dims.height})")
        .call(yaxis)

    {plot, x, y}
