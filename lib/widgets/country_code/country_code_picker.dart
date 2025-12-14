import 'package:country_code_picker/country_code_picker.dart'
    hide SelectionDialog, CountryCode;
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:aiSeaSafe/utils/constants/color_constant.dart';
import 'package:aiSeaSafe/utils/helper/sized_box.dart';
import 'package:aiSeaSafe/widgets/country_code/country_code.dart';
import 'package:aiSeaSafe/widgets/country_code/country_code_selection_dialog.dart';

class CountryCodePicker extends StatefulWidget {
  final ValueChanged<CountryCode>? onChanged;
  final ValueChanged<CountryCode?>? onInit;
  final String? initialSelection;
  final String? headerText;
  final List<String> favorite;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final bool showCountryOnly;
  final bool showCountryCodeOnly;
  final bool hideHeaderText;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? dialogTextStyle;
  final TextStyle? headerTextStyle;
  final WidgetBuilder? emptySearchBuilder;
  final Function(CountryCode?)? builder;
  final bool enabled;
  final TextOverflow textOverflow;
  final Icon closeIcon;

  /// Barrier color of ModalBottomSheet
  final Color? barrierColor;

  /// Background color of ModalBottomSheet
  final Color? backgroundColor;

  /// BoxDecoration for dialog
  final BoxDecoration? boxDecoration;

  /// the size of the selection dialog
  final Size? dialogSize;

  /// Background color of selection dialog
  final Color? dialogBackgroundColor;

  /// used to customize the country list
  final List<String>? countryFilter;

  /// shows the name of the country instead of the dialCode
  final bool showOnlyCountryWhenClosed;

  /// aligns the flag and the Text left
  ///
  /// additionally this option also fills the available space of the widget.
  /// this is especially useful in combination with [showOnlyCountryWhenClosed],
  /// because longer country names are displayed in one line
  final bool alignLeft;

  /// shows the flag
  final bool showFlag;

  final bool hideMainText;
  final bool showCountryCode;

  final bool? showFlagMain;

  final bool? showFlagDialog;

  /// Width of the flag images
  final double flagImageWidth;
  final double flagHeight;
  final double flagWidth;

  /// Use this property to change the order of the options
  final Comparator<CountryCode>? comparator;

  /// Set to true if you want to hide the search part
  final bool hideSearch;

  /// Set to true if you want to hide the close icon dialog
  final bool hideCloseIcon;

  /// Set to true if you want to show drop down button
  final bool showDropDownButton;
  final bool showDivider;
  final EdgeInsetsGeometry? margin;

  /// [BoxDecoration] for the flag image
  final Decoration? flagDecoration;

  /// An optional argument for injecting a list of countries
  /// with customized codes.
  final List<Map<String, String>> countryList;

  final EdgeInsetsGeometry dialogItemPadding;

  final EdgeInsetsGeometry searchPadding;

  const CountryCodePicker({
    this.onChanged,
    this.onInit,
    this.margin,
    this.initialSelection,
    this.favorite = const [],
    this.textStyle,
    this.padding = const EdgeInsets.all(0),
    this.showCountryOnly = false,
    this.showCountryCodeOnly = false,
    this.hideHeaderText = false,
    this.searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.dialogTextStyle,
    this.headerTextStyle,
    this.emptySearchBuilder,
    this.showOnlyCountryWhenClosed = false,
    this.alignLeft = false,
    this.showFlag = true,
    this.showFlagDialog,
    this.hideMainText = true,
    this.showCountryCode = false,
    this.showFlagMain,
    this.flagDecoration,
    this.builder,
    this.flagImageWidth = 25,
    this.flagWidth = 20,
    this.flagHeight = 15,
    this.enabled = true,
    this.textOverflow = TextOverflow.ellipsis,
    this.barrierColor,
    this.backgroundColor,
    this.boxDecoration,
    this.comparator,
    this.countryFilter,
    this.hideSearch = false,
    this.hideCloseIcon = false,
    this.showDropDownButton = false,
    this.showDivider = false,
    this.dialogSize,
    this.headerText,
    this.dialogBackgroundColor,
    this.closeIcon = const Icon(Icons.close),
    this.countryList = codes,
    this.dialogItemPadding = const EdgeInsets.all(0),
    this.searchPadding = const EdgeInsets.symmetric(horizontal: 24),
    super.key,
  });

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    List<Map<String, String>> jsonList = countryList;

    List<CountryCode> elements = jsonList
        .map((json) => CountryCode.fromJson(json))
        .toList();

    if (comparator != null) {
      elements.sort(comparator);
    }

    if (countryFilter != null && countryFilter!.isNotEmpty) {
      final uppercaseCustomList = countryFilter!
          .map((criteria) => criteria.toUpperCase())
          .toList();
      elements = elements
          .where(
            (criteria) =>
                uppercaseCustomList.contains(criteria.code) ||
                uppercaseCustomList.contains(criteria.name) ||
                uppercaseCustomList.contains(criteria.dialCode),
          )
          .toList();
    }

    return CountryCodePickerState(elements);
  }
}

class CountryCodePickerState extends State<CountryCodePicker> {
  CountryCode? selectedItem;
  List<CountryCode> elements = [];
  List<CountryCode> favoriteElements = [];

  CountryCodePickerState(this.elements);

  @override
  Widget build(BuildContext context) {
    Widget internalWidget;
    if (widget.builder != null) {
      internalWidget = InkWell(
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        focusColor: Colors.transparent,
        onTap: widget.enabled ? showCountryCodePickerDialog : null,
        child: widget.builder!(selectedItem),
      );
    } else {
      internalWidget = TextButton(
        style: ButtonStyle(
          visualDensity: const VisualDensity(horizontal: -2),
          padding: WidgetStatePropertyAll(
            EdgeInsets.only(
              left: 5.sp,
              right: selectedItem!.dialCode!.length > 2 ? 5.sp : 10.sp,
            ),
          ),
        ),
        onPressed: widget.enabled ? showCountryCodePickerDialog : null,
        child: Padding(
          padding: widget.padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (widget.showFlagMain != null
                  ? widget.showFlagMain!
                  : widget.showFlag)
                Padding(
                  padding: EdgeInsets.zero,
                  child: Container(
                    clipBehavior: widget.flagDecoration == null
                        ? Clip.none
                        : Clip.hardEdge,
                    decoration: widget.flagDecoration,
                    padding: EdgeInsets.zero,
                    margin:
                        widget.margin ??
                        (widget.alignLeft
                            ? const EdgeInsets.only(right: 16.0, left: 8.0)
                            : const EdgeInsets.only(right: 16.0)),
                    width: widget.flagWidth,
                    height: widget.flagHeight,
                    child: Image.asset(
                      selectedItem!.flagUri!,
                      package: 'country_code_picker',
                      width: widget.flagImageWidth,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              if (!widget.hideMainText) ...[
                SizedBoxW5(),
                Text(
                  widget.showOnlyCountryWhenClosed
                      ? selectedItem!.toCountryStringOnly()
                      : selectedItem.toString(),
                  style:
                      widget.textStyle ??
                      Theme.of(context).textTheme.labelMedium,
                  overflow: widget.textOverflow,
                  textScaler: TextScaler.linear(1.0),
                ),
              ] else ...[
                const SizedBox.shrink(),
              ],
              if (widget.showCountryCode) ...[
                SizedBoxW5(),
                Text(
                  selectedItem!.toCountryCodeStringOnly(),
                  style:
                      widget.textStyle ??
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                  overflow: widget.textOverflow,
                  textScaler: TextScaler.linear(1.0),
                ),
              ] else ...[
                const SizedBox.shrink(),
              ],
              if (widget.showDropDownButton) ...[
                SizedBoxW10(),
                Padding(
                  padding: EdgeInsets.zero,
                  child: Icon(Icons.arrow_downward_rounded),
                ),
              ],
              if (widget.showDivider) SizedBoxW10(),
              if (widget.showDivider)
                Container(
                  width: 2.sp,
                  height: 25.sp,
                  color: ColorConst.colorDCDCDC,
                ),
              SizedBoxW3(),
            ],
          ),
        ),
      );
    }
    return internalWidget;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    elements = elements.map((element) => element.localize(context)).toList();
    _onInit(selectedItem);
  }

  @override
  void didUpdateWidget(CountryCodePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSelection != widget.initialSelection) {
      if (widget.initialSelection != null) {
        selectedItem = elements.firstWhere(
          (criteria) =>
              (criteria.code!.toUpperCase() ==
                  widget.initialSelection!.toUpperCase()) ||
              (criteria.dialCode == widget.initialSelection) ||
              (criteria.name!.toUpperCase() ==
                  widget.initialSelection!.toUpperCase()),
          orElse: () => elements[0],
        );
      } else {
        selectedItem = elements[0];
      }
      _onInit(selectedItem);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialSelection != null) {
      selectedItem = elements.firstWhere(
        (item) =>
            (item.code!.toUpperCase() ==
                widget.initialSelection!.toUpperCase()) ||
            (item.dialCode == widget.initialSelection) ||
            (item.name!.toUpperCase() ==
                widget.initialSelection!.toUpperCase()),
        orElse: () => elements[0],
      );
    } else {
      selectedItem = elements[0];
    }

    favoriteElements = elements
        .where(
          (item) =>
              widget.favorite.firstWhereOrNull(
                (criteria) =>
                    item.code!.toUpperCase() == criteria.toUpperCase() ||
                    item.dialCode == criteria ||
                    item.name!.toUpperCase() == criteria.toUpperCase(),
              ) !=
              null,
        )
        .toList();
  }

  void showCountryCodePickerDialog() async {
    final item = await showDialog(
      // barrierColor: widget.barrierColor ?? Colors.grey.withOpacity(0.5),
      context: context,
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Dialog(
              child: SelectionDialog(
                headerAlignment: MainAxisAlignment.center,
                hideHeaderText: widget.hideHeaderText,
                headerText: widget.headerText,
                headerTextStyle: widget.headerTextStyle ?? TextStyle(),
                topBarPadding: EdgeInsets.zero,
                elements,
                favoriteElements,
                showCountryOnly: widget.showCountryOnly,
                showCountryCodeOnly: widget.showCountryCodeOnly,
                emptySearchBuilder: widget.emptySearchBuilder,
                searchDecoration: widget.searchDecoration,
                searchStyle: widget.searchStyle,
                textStyle: widget.dialogTextStyle,
                boxDecoration: widget.boxDecoration,
                showFlag: widget.showFlagDialog ?? widget.showFlag,
                flagWidth: widget.flagImageWidth,
                size: widget.dialogSize,
                backgroundColor: widget.dialogBackgroundColor,
                barrierColor: widget.barrierColor,
                hideSearch: widget.hideSearch,
                closeIcon: widget.closeIcon,
                flagDecoration: widget.flagDecoration,
                hideCloseIcon: widget.hideCloseIcon,
              ),
            ),
          );
        },
      ),
    );

    if (item != null) {
      setState(() {
        selectedItem = item;
      });

      _publishSelection(item);
    }
  }

  void _publishSelection(CountryCode countryCode) {
    if (widget.onChanged != null) {
      widget.onChanged!(countryCode);
    }
  }

  void _onInit(CountryCode? countryCode) {
    if (widget.onInit != null) {
      widget.onInit!(countryCode);
    }
  }
}
