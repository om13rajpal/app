import 'package:aiSeaSafe/utils/constants/global_variable.dart';
import 'package:aiSeaSafe/utils/extensions/widget_ex.dart';
import 'package:aiSeaSafe/widgets/country_code/country_code.dart';
import 'package:aiSeaSafe/widgets/theme/app_textfield.dart';
import 'package:aiSeaSafe/widgets/theme/theme_text.dart';
import 'package:country_code_picker/country_code_picker.dart' hide CountryCode;
import 'package:flutter/material.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final bool? showCountryOnly;
  final bool? showCountryCodeOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? textStyle;
  final TextStyle headerTextStyle;
  final BoxDecoration? boxDecoration;
  final WidgetBuilder? emptySearchBuilder;
  final bool? showFlag;
  final double flagWidth;
  final Decoration? flagDecoration;
  final Size? size;
  final bool hideSearch;
  final bool hideCloseIcon;
  final Icon? closeIcon;
  final bool hideHeaderText;
  final String? headerText;
  final EdgeInsets topBarPadding;
  final MainAxisAlignment headerAlignment;

  /// Background color of SelectionDialog
  final Color? backgroundColor;

  /// Boxshaow color of SelectionDialog that matches CountryCodePicker barrier color
  final Color? barrierColor;

  /// elements passed as favorite
  final List<CountryCode> favoriteElements;

  final EdgeInsetsGeometry dialogItemPadding;

  final EdgeInsetsGeometry searchPadding;

  SelectionDialog(
    this.elements,
    this.favoriteElements, {
    super.key,
    this.showCountryOnly,
    this.showCountryCodeOnly,
    required this.hideHeaderText,
    this.emptySearchBuilder,
    required this.headerAlignment,
    required this.headerTextStyle,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.textStyle,
    required this.topBarPadding,
    this.headerText,
    this.boxDecoration,
    this.showFlag,
    this.flagDecoration,
    this.flagWidth = 32,
    this.size,
    this.backgroundColor,
    this.barrierColor,
    this.hideSearch = false,
    this.hideCloseIcon = false,
    this.closeIcon,
    this.dialogItemPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.searchPadding = const EdgeInsets.symmetric(horizontal: 24),
  }) : searchDecoration = searchDecoration.prefixIcon == null ? searchDecoration.copyWith(prefixIcon: const Icon(Icons.search)) : searchDecoration;

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  late List<CountryCode> filteredElements;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(0.0),
    child: Container(
      clipBehavior: Clip.hardEdge,
      width: widget.size?.width ?? MediaQuery.of(context).size.width,
      height: widget.size?.height ?? MediaQuery.of(context).size.height * 0.55,
      decoration:
          widget.boxDecoration ??
          BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            // boxShadow: [
            //   BoxShadow(
            //     color: widget.barrierColor ?? Colors.grey.withAlpha(255),
            //     spreadRadius: 5,
            //     blurRadius: 7,
            //     offset: const Offset(0, 3), // changes position of shadow
            //   ),
            // ],
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: !widget.hideHeaderText ? widget.topBarPadding : EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: widget.headerAlignment,
              children: [
                if (!widget.hideHeaderText && widget.headerText != null) ...[
                  Text(widget.headerText!, overflow: TextOverflow.fade, style: widget.headerTextStyle).applyPaddingOnly(top: kDefaultPaddingValue, bottom: kDefaultPaddingValue),
                ],
                if (!widget.hideCloseIcon) IconButton(padding: const EdgeInsets.all(0), iconSize: 20, icon: widget.closeIcon!, onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          if (!widget.hideSearch) ...[
            LabelTextField(
              labelTextVisible: false,
              // borderRadius: ,
              textInputType: TextInputType.text,
              style: widget.searchStyle,
              onChanged: _filterElements,
              hintText: 'Search',

              contentPadding: EdgeInsets.only(left: 10),
            ).applyPaddingAll(5),
            // Divider(),
          ],
          Expanded(
            child: ListView(
              children: [
                widget.favoriteElements.isEmpty
                    ? const DecoratedBox(decoration: BoxDecoration())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...widget.favoriteElements.map(
                            (f) => InkWell(
                              onTap: () {
                                _selectItem(f);
                              },
                              child: Padding(padding: widget.dialogItemPadding, child: _buildOption(f)),
                            ),
                          ),
                          // Divider(color: ColorsConst.colorC7C7C7)
                          //     .applyPaddingHorizontal(),
                        ],
                      ),
                if (filteredElements.isEmpty)
                  _buildEmptySearchWidget(context)
                else
                  ...filteredElements.map(
                    (e) => Column(
                      children: [
                        InkWell(
                          onTap: () {
                            _selectItem(e);
                          },
                          child: Padding(padding: widget.dialogItemPadding, child: _buildOption(e)),
                        ),
                        // Divider(color: ColorsConst.colorC7C7C7)
                        //     .applyPaddingHorizontal(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildOption(CountryCode e) {
    return SizedBox(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          if (widget.showFlag!)
            Flexible(
              child: Container(
                margin:
                    Directionality.of(context) ==
                        TextDirection
                            .ltr // Here Adding padding depending on the locale language direction
                    ? const EdgeInsets.only(right: 16.0)
                    : const EdgeInsets.only(left: 16.0),
                decoration: widget.flagDecoration,
                clipBehavior: widget.flagDecoration == null ? Clip.none : Clip.hardEdge,
                child: Image.asset(e.flagUri!, package: 'country_code_picker', width: widget.flagWidth),
              ),
            ),
          Expanded(
            flex: 4,
            child: ThemeText(
              text: widget.showCountryCodeOnly!
                  ? e.toLongString().split(' ').first
                  : widget.showCountryOnly!
                  ? e.toCountryStringOnly()
                  : e.toLongString(),
              textOverflow: TextOverflow.fade,
              style: widget.textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }

    return Center(child: Text(CountryLocalizations.of(context)?.translate('no_country') ?? 'No country found', textScaler: TextScaler.linear(1.0)));
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements.where((e) => e.code!.contains(s) || e.dialCode!.contains(s) || e.name!.toUpperCase().contains(s)).toList();
    });
  }

  void _selectItem(CountryCode e) {
    Navigator.pop(context, e);
  }
}
