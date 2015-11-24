var day = '01';
var month = 'JAN';
var year = '2011';
var hour = '12';
var min = '00';


if(parseInt(hour) < 10) {
	hour = ' ' + hour
}

enyo.kind({
	name: 'layout.digitalClock',
	height: '550px',
	width:'810px',
	className: 'digitalClock digital',
	kind: 'VFlexBox',
	components: [
		{kind: "HFlexBox", components: [
			{name: '', className: 'time digital-hour',  pack: 'center', align: 'center', components:[
				{content: hour[0], className:'digit'},
				{content: 'AM', className:'time-meridian'},
				{kind: 'Image', src: 'digital_landscape_time_bg.png', className: 'digit-hour-overlay'}
			]},
			{name: '', className: 'time digital-hour',  pack: 'center', align: 'center', components:[
				{content: hour[1], className:'digit'},
				{kind: 'Image', src: 'digital_landscape_time_bg.png', className: 'digit-hour-overlay'}
			]},
			{layoutKind:'VFlexLayout', pack:'center', align: 'center', height: '220px', components: [
				{content: ":", className:'clock-separator'}
			]},
			{name: '', className: 'time digital-min', pack: 'center', align: 'center', components:[
				{content: min[0], className:'digit'},
				{kind: 'Image', src: 'digital_landscape_time_bg.png', className: 'digit-hour-overlay'}
			]},
			{name: '', className: 'time digital-min', pack: 'center', align: 'center', components:[
				{content: min[1], className:'digit'},
				{kind: 'Image', src: 'digital_landscape_time_bg.png', className: 'digit-hour-overlay'}
			]},
		]},
		{kind: 'HFlexBox', name: '', components: [
			{kind:'HFlexBox', name: '', pack: 'center', align: 'center',  style:'position:relative', components: [
				{content: month[0], className: 'date digital-month'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
				{content: month[1],  className: 'date digital-month'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
				{content: month[2],  className: 'date digital-month'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'}
			]},
			{kind: 'HFlexBox', pack: 'center', align: 'center',  components:[
				{className: 'date',content: '&nbsp;'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
			]},
			{kind:'HFlexBox', name: '', pack: 'center', align: 'center',  components: [
				{content: day[0], className: 'date digital-day'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
				{content: day[1], className: 'date digital-day'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
			]},
			{kind: 'HFlexBox', pack: 'center', align: 'center',  components:[
				{className: 'date',content: '&nbsp;'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
			]},
			{kind: 'HFlexBox', pack: 'center', align: 'center',  components:[
				{content: year[0], className: 'date digital-year'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
				{content: year[1], className: 'date digital-year'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
				{content: year[2], className: 'date digital-year'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
				{content: year[3], className: 'date digital-year'},
				{kind: 'Image', src: 'digital_landscape_date_bg.png', className: 'digit-date-overlay'},
			]},
		]}
	]
});