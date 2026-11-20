import 'package:flutter/material.dart';

import '../models/models.dart';

const BusinessType personalType =
    BusinessType('personal', 'ব্যক্তিগত হিসাব', Icons.person_outline);

const List<BusinessType> businessTypes = [
  BusinessType('grocery', 'মুদি বা জেনারেল স্টোর', Icons.shopping_basket),
  BusinessType('fashion', 'ফ্যাশন বা কাপড়ের ব্যবসা', Icons.checkroom),
  BusinessType('mobile_banking', 'মোবাইল ব্যাংকিং ও রিচার্জ পয়েন্ট',
      Icons.phone_android),
  BusinessType('bakery', 'বেকারি ও কনফেকশনারি', Icons.cake),
  BusinessType('furniture', 'গৃহস্থালি ও ফার্নিচার', Icons.chair),
  BusinessType('stationery', 'লাইব্রেরি ও স্টেশনারী', Icons.edit),
  BusinessType('shoes', 'জুতার দোকান', Icons.directions_walk),
  BusinessType('dealer', 'ডিলার/ডিস্ট্রিবিউটর বা পাইকারি ব্যবসা',
      Icons.local_shipping),
  BusinessType('hardware', 'হার্ডওয়্যার', Icons.hardware),
  BusinessType('pharmacy', 'ফার্মেসি', Icons.medication),
  BusinessType('cosmetics', 'কসমেটিকস, বিউটি ও জুয়েলারি', Icons.brush),
  BusinessType('restaurant', 'রেস্টুরেন্ট বা মিষ্টির দোকান', Icons.restaurant),
  BusinessType('electronics', 'মোবাইল, কম্পিউটার ও ইলেক্ট্রনিক্স',
      Icons.router),
  BusinessType('agri', 'কৃষি পণ্য ও উপকরণ', Icons.eco),
  BusinessType('construction', 'রড-সিমেন্ট/নির্মাণ সামগ্রী', Icons.construction),
  BusinessType('auto', 'গাড়ি ও অটো পার্টস', Icons.car_repair),
  BusinessType('tailors', 'টেইলার্স', Icons.content_cut),
  BusinessType('other', 'অন্যান্য', Icons.storefront),
];
