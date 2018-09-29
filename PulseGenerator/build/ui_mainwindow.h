/********************************************************************************
** Form generated from reading UI file 'mainwindow.ui'
**
** Created by: Qt User Interface Compiler version 5.8.0
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAINWINDOW_H
#define UI_MAINWINDOW_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QDial>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLCDNumber>
#include <QtWidgets/QLabel>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSlider>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QToolBar>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_MainWindow
{
public:
    QWidget *centralWidget;
    QLCDNumber *lcdNumberFrequency;
    QLCDNumber *lcdNumberDutyCycle;
    QDial *dialDutyCycle;
    QPushButton *pushButtonGetVersion;
    QPushButton *pushButtonUpgradeFirmware;
    QLabel *label;
    QGroupBox *groupBox;
    QDial *dialFine;
    QLabel *label_3;
    QLabel *label_2;
    QDial *dialCoarse;
    QSlider *verticalSliderRange;
    QMenuBar *menuBar;
    QToolBar *mainToolBar;
    QStatusBar *statusBar;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName(QStringLiteral("MainWindow"));
        MainWindow->resize(563, 334);
        centralWidget = new QWidget(MainWindow);
        centralWidget->setObjectName(QStringLiteral("centralWidget"));
        lcdNumberFrequency = new QLCDNumber(centralWidget);
        lcdNumberFrequency->setObjectName(QStringLiteral("lcdNumberFrequency"));
        lcdNumberFrequency->setGeometry(QRect(30, 30, 291, 91));
        lcdNumberDutyCycle = new QLCDNumber(centralWidget);
        lcdNumberDutyCycle->setObjectName(QStringLiteral("lcdNumberDutyCycle"));
        lcdNumberDutyCycle->setGeometry(QRect(330, 30, 221, 91));
        lcdNumberDutyCycle->setProperty("value", QVariant(50));
        dialDutyCycle = new QDial(centralWidget);
        dialDutyCycle->setObjectName(QStringLiteral("dialDutyCycle"));
        dialDutyCycle->setGeometry(QRect(340, 140, 111, 101));
        dialDutyCycle->setMaximum(100);
        dialDutyCycle->setValue(50);
        pushButtonGetVersion = new QPushButton(centralWidget);
        pushButtonGetVersion->setObjectName(QStringLiteral("pushButtonGetVersion"));
        pushButtonGetVersion->setGeometry(QRect(460, 160, 75, 23));
        pushButtonUpgradeFirmware = new QPushButton(centralWidget);
        pushButtonUpgradeFirmware->setObjectName(QStringLiteral("pushButtonUpgradeFirmware"));
        pushButtonUpgradeFirmware->setGeometry(QRect(460, 190, 75, 23));
        label = new QLabel(centralWidget);
        label->setObjectName(QStringLiteral("label"));
        label->setGeometry(QRect(350, 240, 91, 21));
        QFont font;
        font.setPointSize(12);
        label->setFont(font);
        label->setAlignment(Qt::AlignCenter);
        groupBox = new QGroupBox(centralWidget);
        groupBox->setObjectName(QStringLiteral("groupBox"));
        groupBox->setGeometry(QRect(30, 130, 301, 141));
        dialFine = new QDial(groupBox);
        dialFine->setObjectName(QStringLiteral("dialFine"));
        dialFine->setGeometry(QRect(170, 10, 111, 101));
        dialFine->setMaximum(100);
        label_3 = new QLabel(groupBox);
        label_3->setObjectName(QStringLiteral("label_3"));
        label_3->setGeometry(QRect(60, 110, 91, 21));
        label_3->setFont(font);
        label_3->setAlignment(Qt::AlignCenter);
        label_2 = new QLabel(groupBox);
        label_2->setObjectName(QStringLiteral("label_2"));
        label_2->setGeometry(QRect(180, 110, 91, 21));
        label_2->setFont(font);
        label_2->setAlignment(Qt::AlignCenter);
        dialCoarse = new QDial(groupBox);
        dialCoarse->setObjectName(QStringLiteral("dialCoarse"));
        dialCoarse->setGeometry(QRect(50, 10, 111, 101));
        dialCoarse->setMaximum(100);
        verticalSliderRange = new QSlider(groupBox);
        verticalSliderRange->setObjectName(QStringLiteral("verticalSliderRange"));
        verticalSliderRange->setGeometry(QRect(10, 30, 20, 71));
        verticalSliderRange->setMinimum(1);
        verticalSliderRange->setMaximum(4);
        verticalSliderRange->setPageStep(1);
        verticalSliderRange->setOrientation(Qt::Vertical);
        verticalSliderRange->setTickPosition(QSlider::TicksAbove);
        MainWindow->setCentralWidget(centralWidget);
        menuBar = new QMenuBar(MainWindow);
        menuBar->setObjectName(QStringLiteral("menuBar"));
        menuBar->setGeometry(QRect(0, 0, 563, 21));
        MainWindow->setMenuBar(menuBar);
        mainToolBar = new QToolBar(MainWindow);
        mainToolBar->setObjectName(QStringLiteral("mainToolBar"));
        MainWindow->addToolBar(Qt::TopToolBarArea, mainToolBar);
        statusBar = new QStatusBar(MainWindow);
        statusBar->setObjectName(QStringLiteral("statusBar"));
        MainWindow->setStatusBar(statusBar);

        retranslateUi(MainWindow);
        QObject::connect(dialDutyCycle, SIGNAL(valueChanged(int)), lcdNumberDutyCycle, SLOT(display(int)));

        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QApplication::translate("MainWindow", "MainWindow", Q_NULLPTR));
        pushButtonGetVersion->setText(QApplication::translate("MainWindow", "Version?", Q_NULLPTR));
        pushButtonUpgradeFirmware->setText(QApplication::translate("MainWindow", "Upgrade FW", Q_NULLPTR));
        label->setText(QApplication::translate("MainWindow", "Duty Cycle", Q_NULLPTR));
        groupBox->setTitle(QApplication::translate("MainWindow", "Frequency", Q_NULLPTR));
        label_3->setText(QApplication::translate("MainWindow", "Coarse", Q_NULLPTR));
        label_2->setText(QApplication::translate("MainWindow", "Fine", Q_NULLPTR));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
