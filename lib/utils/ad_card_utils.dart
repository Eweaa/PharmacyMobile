import 'package:flutter/material.dart';
import 'package:test_applicaiton_1/l10n/app_localizations.dart';

class AdCardUtils {

  static Widget getStatusText(int statusId, String lang) {
    
    switch (statusId) {
      case 111:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
          AppLocalizations.translate('status_posted', lang),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
      );
      case 112:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
          AppLocalizations.translate('status_declined', lang),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
      );
      case 113:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
          AppLocalizations.translate('status_pending', lang),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
      );
      case 114:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
          AppLocalizations.translate('status_closed', lang),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
      );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
          AppLocalizations.translate('status_unknown', lang),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
      );
    }
  }

  static Widget showAcceptBtn(int statusId, int adId, Function(int, int) onAccept, String lang) 
  {
    if(statusId != 111)
    {
      return IconButton(
        icon: const Icon(Icons.check_circle, size: 20),
        color: Colors.green,
        tooltip: AppLocalizations.translate('accept_ad', lang),
        onPressed: () {
          // Call the callback function with ad ID and status ID 111
          onAccept(adId, 111);
        },
      );
    }
    else
    {
      return Container();
    }
  }
}