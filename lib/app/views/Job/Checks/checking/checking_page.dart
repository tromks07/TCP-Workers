import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tcp_workers/app/Style/Colors.dart';
import 'package:tcp_workers/app/Style/text.dart';
import 'package:time_range_picker/time_range_picker.dart';
import '../../../../common/progressBar.dart';
import '../checking/checking_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';

class CheckinPage extends StatefulWidget {
  @override
  _CheckinPageState createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  TimeRange range = TimeRange(
      startTime: TimeOfDay(hour: 0, minute: 00),
      endTime: TimeOfDay(hour: 0, minute: 00));

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckingCtrl>(
        init: CheckingCtrl(),
        builder: (_) => Scaffold(
              appBar: AppBar(
                title: new Column(children: [
                  Text(_.jobData.name.toUpperCase(), style: subTitleWhiteFont),
                  SizedBox(
                    height: 3,
                  ),
                  Text('Checking page', style: minimalWhiteFont),
                ]),
                centerTitle: true,
                backgroundColor: main_color,
                primary: true,
              ),
              body: Obx(
                () => _.isVerifying.value
                    ? MyProgressBar()
                    : Center(
                        child: SingleChildScrollView(
                          child: _checkIn(ctrl: _, context: context),
                        ),
                      ),
              ),
            ));
  }

  _checkIn({CheckingCtrl ctrl, BuildContext context}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      TextButton.icon(
          onPressed: () => ctrl.pickDate(context),
          icon: Icon(Icons.edit),
          label: Text(
              DateFormat.yMMMMEEEEd().format(ctrl.date.value).toString(),
              style: titleFont)),
      new Column(
        children: [
          Obx(() => Text(ctrl.hourWorked.value.toString(), style: titleFont)),
          new Text('hours worked', style: titleFont),
        ],
      ),
      dataColumn(ctrl: ctrl),
      new Column(
        children: [
          Obx(() => Text(ctrl.payment.value.toString(), style: titleFont)),
          new Text('payment (\$)', style: titleFont),
        ],
      ),
      SizedBox(height: 45.sp),
      ctrl.jobData.type == "hour"
          ? InkWell(
              onTap: () async {
                TimeRange data = await showTimeRangePicker(
                  start: TimeOfDay(hour: 7, minute: 0),
                  end: TimeOfDay(hour: 17, minute: 0),
                  interval: Duration(minutes: 30),
                  context: context,
                );
                if (data != null) {
                  setState(() => range = data);
                  ctrl.calculateHoursWorked(time: range);
                }
              },
              child: Card(
                child: new ListTile(
                  title: new Text(
                    'select check-in and check-out time',
                    style: subTitleFont,
                    textAlign: TextAlign.center,
                  ),
                  trailing: new Icon(Icons.touch_app, color: main_color),
                ),
              ),
            )
          : SizedBox(),
      SizedBox(
        height: 20,
      ),
      ctrl.jobData.type == "hour" ? _timeSelect(ctrl: ctrl) : SizedBox(),
      SizedBox(height: 50.sp),
      RoundedLoadingButton(
        color: main_color,
        errorColor: Colors.red,
        successColor: Colors.green,
        child: Text('Check day'.toUpperCase(),
            style: TextStyle(color: Colors.white)),
        controller: ctrl.btnController,
        onPressed: () => ctrl.setCheck(timeFromUI: range),
      )
    ]);
  }

  Widget dataColumn({CheckingCtrl ctrl}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ctrl.jobData.type == "hour"
            ? Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                new Text(range.startTime.format(context), style: titleFont),
                new Text('In', style: subTitleFont)
              ])
            : Container(),
        Container(
          color: main_color,
          height: 1.sp,
          width: 25.sp,
        ),
        ctrl.jobData.type == "hour"
            ? Column(children: [
                new Text(range.endTime.format(context), style: titleFont),
                new Text('Out', style: subTitleFont)
              ])
            : Container()
      ],
    );
  }

  Widget _timeSelect({CheckingCtrl ctrl}) {
    return new Container(
        child: Card(
            child: ListTile(
      subtitle: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Text(
            'Lunch minutes',
            style: bodyFontBold,
          ),
          SizedBox(width: 10.sp),
          new Icon(CupertinoIcons.hand_draw, size: 15.sp, color: main_color)
        ],
      ),
      title: Obx(() => NumberPicker(
            itemWidth: Get.width / 3,
            haptics: true,
            step: 15,
            selectedTextStyle: TextStyle(
                fontSize: 20,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold),
            textStyle: subTitleFont,
            axis: Axis.horizontal,
            value: ctrl.breakTime.value,
            minValue: 0,
            maxValue: 90,
            onChanged: (newValue) async {
              ctrl.breakTime.value = newValue;
              ctrl.calculateHoursWorked(time: range);
            },
          )),
    )));
  }
}
