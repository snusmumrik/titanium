# globals Ti, Titanium, JSON, alert

Ti.include 'facebook_login.js'

b1 = Ti.UI.createButton
  title:'Run Query'
  width:200
  height:40
  top:100

win.add b1

runQuery = ->
  b1.title = 'Loading...'
  tableView = Ti.UI.createTableView minRowHeight:100
  win = Ti.UI.createWindow title:'Facebook Query'
  win.add tableView

  # create close button on window nav
  close = Ti.UI.createButton
    title:'Close'
  close.addEventListener 'click', () -> win.close()
  if Ti.Platform.osname == 'iphone' || Ti.Platform.osname == 'ipad'
    win.setRightNavButton(close)

  # run query, populate table view and open window
  query = "SELECT uid, name, pic_square, status FROM user
    where uid IN (SELECT uid2 FROM friend WHERE uid1 = #{Titanium.Facebook.uid}) order by last_name limit 20"
  Ti.API.info 'user id ' + Ti.Facebook.uid
  Ti.Facebook.request 'fql.query', {query: query}, (r) ->
    unless r.success
      if r.error
        alert r.error
      else
        alert "call was unsuccessful"
      return

    result = JSON.parse(r.result)
    data = []
    c = 0

    while c < result.length
      row = result[c]
      tvRow = Ti.UI.createTableViewRow
        height:'auto'
        selectedBackgroundColor:'#fff'
        backgroundColor:'#fff'

      imageView = Ti.UI.createImageView
        image:if row.pic_square == null then '../images/custom_tableview/user.png' else row.pic_square
        left:10
        width:50
        height:50
      tvRow.add imageView

      userLabel = Ti.UI.createLabel
        font:{fontSize:16, fontWeight:'bold'}
        left:70
        top:5
        right:5
        height:20
        color:'#576996'
        text:row.name
      tvRow.add userLabel

      statusLabel = Ti.UI.createLabel
        font:{fontSize:13}
        left:70
        top:25
        right:20
        height:'auto'
        color:'#222'
        text:(if not row.status or not row.status.message then 'No status message' else row.status.message)
      tvRow.add statusLabel
      tvRow.uid = row.uid
      data[c] = tvRow
      c++
    tableView.setData data, { animationStyle : Ti.UI.iPhone.RowAnimationStyle.DOWN }

    win.open modal:true
    b1.title = 'Run Query'

b1.addEventListener 'click', () ->
  unless Ti.Facebook.loggedIn
    Ti.UI.createAlertDialog({title:'Facebook', message:'Login before running query'}).show()
    return
  runQuery()
