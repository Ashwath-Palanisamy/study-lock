import 'package:flutter/material.dart';
import 'package:studylock/components/app_buttons.dart';
import 'package:studylock/components/app_section.dart';
import 'package:studylock/components/app_text.dart';

class ChoicePageView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose an option')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column( // Body content
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.title('Choose one'),
                      AppText.body('Choose what you want your study partner to do?'),

                      // option sections
                      SizedBox(height: 16,),
                      AppSection(child: Column(
                        children: [
                          AppButtons(child: Text('Explain Topics?'), onPressed: () {
                            
                          },),

                          SizedBox(height: 16,),
                          
                          AppButtons(child: Text('Test you with MCQs?'), onPressed: () {
                            
                          },)
                        ],
                      ))
      
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
