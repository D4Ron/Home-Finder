import 'package:flutter/material.dart';
import '../utils/colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            //Background Image/Image d'arrière-plan
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcome_screen.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken,)
                )
              )
            ),

            //Content Overlay,le contenu qu'on superpose sur l'image d'arrière-plan
            //SafeArea adds by default some amount of padding to its child to prevent it from conflicting with notches and etc..
            SafeArea(
              child: Column(
                children:[
                  //Using a spacer to push content downwards
                  const Spacer(flex: 3),
                  //The actual text
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Trouver votre',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 32,
                            fontWeight: FontWeight.w400
                          ),
                          textAlign: TextAlign.center,
                        ),
                        //This text is separated so it can be boldened for a better presentation
                        Text(
                          'Endroit Ideal',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 40,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        //Subtitle think of it like a <p> in html
                        Text(
                          'Trouve un endroit pour passer le\nreste de la journée à l\'intérieur de la maison',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                          ),

                          textAlign: TextAlign.center,
                        ),



                      ]
                    )
                  ),
                  //Same logic as the one above
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (){
                          print('Commenccer button pressed');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        )

                      )
                    ),
                  ),
                  const SizedBox(height: 48,)
                ]
              )
            )
          ]
        )
    );
  }
}