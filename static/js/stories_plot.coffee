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

    configure_viewport: (elem, x_domain, y_domain, xtime=false) ->
        # Viewport configuration boilerplate
        # Returns:
        #     plot: the plot element (a d3 selection)
        #     x: d3.scale object for x dimension
        #     y: d3.scale object for y dimension

        container = d3.select(elem)

        # Set viewport dimensions
        margins = {top: 10, right: 20, bottom: 30, left: 60}
        svg_dims =
            width: @width()
            height: @height()
        plot_dims = {
            width: svg_dims.width - margins.left - margins.right
            height: svg_dims.height - margins.top - margins.bottom
        }

        # Create the plot element
        svg = container.append('svg')
            .attr('width', svg_dims.width)
            .attr('height', svg_dims.height)
        plot = svg.append('g')
            .attr('transform', "translate(#{margins.left}, #{margins.top})")

        # Create x- and y- scales
        if xtime
            x = d3.time.scale()
                .domain(x_domain)
                .range([0, plot_dims.width])
        else
            x = d3.scale.linear()
                .domain(x_domain)
                .range([0, plot_dims.width])
        y = d3.scale.linear()
            .domain(y_domain)
            .range([plot_dims.height, 0])

        # x- and y- axes
        xaxis = d3.svg.axis()
            .scale(x)
        yaxis = d3.svg.axis()
            .scale(y)
            .orient('left')

        plot.append('g')
            .attr('class', 'x axis')
            .attr('transform', "translate(0, #{plot_dims.height})")
            .call(xaxis)

        plot.append('g')
            .attr('class', 'y axis')
            .call(yaxis)

        {plot, x, y}


class window.Plot extends BasePlot

    constructor: ->
        super()

        @tooltip = d3.select("body").append("div")
            .style("display", "none")
            .style("background-color", "#eee")
            .style("background-color", "rgba(242, 242, 242, .6)")
            .style("padding", "5px")
            .style("position", "absolute")

    _draw: (elem, data) ->

        # Compute x- and y-domains
        for d in data
            data.timestamp = new Date(data.timestamp)
        x_domain = d3.extent(data, (d) -> d.timestamp)
        y_domain = d3.extent(data, (d) -> d.comments)

        author_counts = d3.nest()
            .key((story) -> story.author)
            .rollup((group) -> group.length)
            .map(data)

        color = d3.scale.category10()
            .domain(d3.keys(author_counts).sort())

        # Off-the-shelf viewport
        {plot, x, y} = @configure_viewport(elem, x_domain, y_domain, true)

        # Add data points
        points = plot.selectAll('circle').data(data)

        points.enter()
            .append('circle')
            .attr('cx', (d) -> x(d.timestamp))
            .attr('cy', (d) -> y(d.comments))
            .attr('r', 5)
            .attr('fill', (d) -> color(d.author))

        line = d3.svg.line()
            .x((d) -> x(d.timestamp))
            .y((d) -> y(d.comments))

        plot.append('path')
            .attr('d', line(data))
            .style('stroke', 'blue')
            .style('fill', 'none')

        plot.selectAll('circle')
            .on('mouseover', (d) =>
                @show_tooltip("#{d.title}<br>#{d.author}"))
            .on('mouseout', (d) =>
                @hide_tooltip())


    show_tooltip: (html) =>
        m = d3.mouse(d3.select("body").node())
        @tooltip.style("display", null)
            .style("left", m[0] + 30 + "px")
            .style("top", m[1] - 20 + "px")
            .html(html)

    hide_tooltip: =>
        @tooltip.style("display", "none")
