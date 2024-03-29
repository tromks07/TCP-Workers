import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:tcp_workers/app/Style/Colors.dart';
import 'package:tcp_workers/app/Style/text.dart';
import 'package:tcp_workers/app/common/progressBar.dart';
import 'package:tcp_workers/app/common/rounded_secondary_button.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'Check_manage_controller.dart';

class CheckManagementPage extends StatefulWidget {
  @override
  _CheckManagementPageState createState() => _CheckManagementPageState();
}

class _CheckManagementPageState extends State<CheckManagementPage> {
  TimeRange range = TimeRange(
      startTime: TimeOfDay(hour: 00, minute: 00),
      endTime: TimeOfDay(hour: 00, minute: 00));

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckManagementController>(
      init: CheckManagementController(),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: new Column(children: [
            Text(_.jobData.name.toUpperCase(), style: subTitleWhiteFont),
            SizedBox(
              height: 3,
            ),
            Text('Check management', style: minimalWhiteFont),
          ]),
          centerTitle: true,
          backgroundColor: main_color,
          primary: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: _.dat.value == DateTime(2000, 1, 1)
                ? _pickerDate(ctrl: _, context: context)
                : _.fetchingData.value
                    ? MyProgressBar()
                    : _checkIn(ctrl: _, context: context),
          ),
        ),
      ),
    );
  }

  Widget _pickerDate({CheckManagementController ctrl, BuildContext context}) {
    return new Padding(
        padding: EdgeInsets.symmetric(vertical: 7.sp, horizontal: 10.sp),
        child: ElevatedButton(
            child: new Text('Select date', style: subTitleWhiteFont),
            onPressed: () => ctrl.pickDate(context)));
  }

  _checkIn({CheckManagementController ctrl, BuildContext context}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(height: 30),
      Text(DateFormat.yMMMMEEEEd().format(ctrl.checkData.date.toLocal()),
          style: titleFont),
      SizedBox(height: 25.sp),
      new Column(
        children: [
          Text(ctrl.checkData.hours.toString(),
              style: ctrl.checkData.hours > 0
                  ? titleFont
                  : TextStyle(fontSize: 20.sp, color: Colors.red)),
          new Text('hours worked', style: titleFont),
        ],
      ),
      dataColumn(),
      new Column(
        children: [
          Text(ctrl.checkData.payment.toString(), style: titleFont),
          new Text('payment (\$)', style: titleFont),
        ],
      ),
      SizedBox(height: 45.sp),
      InkWell(
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
      ),
      SizedBox(
        height: 20,
      ),
      _timeSelect(ctrl: ctrl),
      SizedBox(height: 50.sp),
      RoundedLoadingButton(
        color: main_color,
        errorColor: Colors.red,
        successColor: Colors.green,
        child: Text('Update check'.toUpperCase(),
            style: TextStyle(color: Colors.white)),
        controller: ctrl.btnController,
        onPressed: () => ctrl.updateCheck(),
      ),
      SizedBox(height: 30),
      Container(
        width: 100,
        child: MySecondaryButton(
          text: "Delete",
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("are you sure you want to delete this check?",
                    style: bodyFontWhiteBold),
                action: SnackBarAction(
                    label: "Yes!", onPressed: () => ctrl.disableCheck())),
          ),
        ),
      ),
      SizedBox(height: 30),
    ]);
  }

  Widget dataColumn({CheckManagementController ctrl}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          new Text(range.startTime.format(context), style: titleFont),
          new Text('In', style: subTitleFont)
        ]),
        Container(
          color: main_color,
          height: 1.sp,
          width: 25.sp,
        ),
        Column(children: [
          new Text(range.endTime.format(context), style: titleFont),
          new Text('Out', style: subTitleFont)
        ])
      ],
    );
  }

  Widget _timeSelect({CheckManagementController ctrl}) {
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
                    new Icon(CupertinoIcons.hand_draw,
                        size: 15.sp, color: main_color)
                  ],
                ),
                title: NumberPicker(
                  itemWidth: Get.width / 3,
                  step: 15,
                  selectedTextStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold),
                  textStyle: titleFont,
                  axis: Axis.horizontal,
                  value: ctrl.checkData.breakMinutes,
                  minValue: 0,
                  maxValue: 90,
                  onChanged: (newValue) async {
                    ctrl.checkData.breakMinutes = newValue;
                    ctrl.calculateHoursWorked(time: range);
                    setState(() {});
                  },
                ))));
  }
}
