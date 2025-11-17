/****************************************************************************
** Meta object code from reading C++ file 'TaskController.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../TaskController.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'TaskController.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.8.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN14TaskControllerE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN14TaskControllerE = QtMocHelpers::stringData(
    "TaskController",
    "currentProjectIdChanged",
    "",
    "loadingChanged",
    "tasksChanged",
    "subTasksChanged",
    "parentTaskId",
    "taskCreated",
    "taskId",
    "taskUpdated",
    "taskDeleted",
    "taskAssigned",
    "employeeId",
    "errorOccurred",
    "errorMessage",
    "taskCreationFailed",
    "taskUpdateFailed",
    "taskDeletionFailed",
    "taskAssignmentFailed",
    "loadTasksForProject",
    "projectId",
    "loadTasksForCurrentProject",
    "createTask",
    "taskName",
    "description",
    "idParentTache",
    "assignedToId",
    "estimatedTime",
    "dateDebut",
    "dateFin",
    "etat",
    "updateTask",
    "updateTaskStatus",
    "deleteTask",
    "assignTask",
    "getTaskDetails",
    "QVariantMap",
    "getSubTasks",
    "QVariantList",
    "createSubTask",
    "subTaskName",
    "deleteSubTask",
    "getTaskHierarchy",
    "getAvailableEmployees",
    "getDepartmentEmployees",
    "getTasksForProject",
    "onRefreshTimerTimeout",
    "getCurrentUser",
    "User*",
    "getTasksForProjectByStatus",
    "status",
    "getSubTasksByStatus",
    "canCreateTask",
    "canEditTask",
    "canDeleteTask",
    "canAssignTask",
    "canChangeStatus",
    "isEmployeeView",
    "currentProjectId",
    "loading",
    "tasks"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN14TaskControllerE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      38,   14, // methods
       3,  392, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
      13,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,  242,    2, 0x06,    4 /* Public */,
       3,    0,  243,    2, 0x06,    5 /* Public */,
       4,    0,  244,    2, 0x06,    6 /* Public */,
       5,    1,  245,    2, 0x06,    7 /* Public */,
       7,    1,  248,    2, 0x06,    9 /* Public */,
       9,    1,  251,    2, 0x06,   11 /* Public */,
      10,    1,  254,    2, 0x06,   13 /* Public */,
      11,    2,  257,    2, 0x06,   15 /* Public */,
      13,    1,  262,    2, 0x06,   18 /* Public */,
      15,    1,  265,    2, 0x06,   20 /* Public */,
      16,    1,  268,    2, 0x06,   22 /* Public */,
      17,    1,  271,    2, 0x06,   24 /* Public */,
      18,    1,  274,    2, 0x06,   26 /* Public */,

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
      19,    1,  277,    2, 0x0a,   28 /* Public */,
      21,    0,  280,    2, 0x0a,   30 /* Public */,
      22,    9,  281,    2, 0x0a,   31 /* Public */,
      31,    8,  300,    2, 0x0a,   41 /* Public */,
      32,    2,  317,    2, 0x0a,   50 /* Public */,
      33,    1,  322,    2, 0x0a,   53 /* Public */,
      34,    2,  325,    2, 0x0a,   55 /* Public */,
      35,    1,  330,    2, 0x0a,   58 /* Public */,
      37,    1,  333,    2, 0x0a,   60 /* Public */,
      39,    8,  336,    2, 0x0a,   62 /* Public */,
      41,    1,  353,    2, 0x0a,   71 /* Public */,
      42,    1,  356,    2, 0x0a,   73 /* Public */,
      43,    0,  359,    2, 0x0a,   75 /* Public */,
      44,    0,  360,    2, 0x0a,   76 /* Public */,
      45,    1,  361,    2, 0x0a,   77 /* Public */,
      46,    0,  364,    2, 0x0a,   79 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
      47,    0,  365,    2, 0x102,   80 /* Public | MethodIsConst  */,
      49,    2,  366,    2, 0x02,   81 /* Public */,
      51,    2,  371,    2, 0x02,   84 /* Public */,
      52,    1,  376,    2, 0x102,   87 /* Public | MethodIsConst  */,
      53,    1,  379,    2, 0x102,   89 /* Public | MethodIsConst  */,
      54,    1,  382,    2, 0x102,   91 /* Public | MethodIsConst  */,
      55,    1,  385,    2, 0x102,   93 /* Public | MethodIsConst  */,
      56,    1,  388,    2, 0x102,   95 /* Public | MethodIsConst  */,
      57,    0,  391,    2, 0x102,   97 /* Public | MethodIsConst  */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    6,
    QMetaType::Void, QMetaType::Int,    8,
    QMetaType::Void, QMetaType::Int,    8,
    QMetaType::Void, QMetaType::Int,    8,
    QMetaType::Void, QMetaType::Int, QMetaType::Int,    8,   12,
    QMetaType::Void, QMetaType::QString,   14,
    QMetaType::Void, QMetaType::QString,   14,
    QMetaType::Void, QMetaType::QString,   14,
    QMetaType::Void, QMetaType::QString,   14,
    QMetaType::Void, QMetaType::QString,   14,

 // slots: parameters
    QMetaType::Void, QMetaType::Int,   20,
    QMetaType::Void,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   20,   23,   24,   25,   26,   27,   28,   29,   30,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    8,   23,   24,   26,   27,   28,   29,   30,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString,    8,   30,
    QMetaType::Bool, QMetaType::Int,    8,
    QMetaType::Bool, QMetaType::Int, QMetaType::Int,    8,   12,
    0x80000000 | 36, QMetaType::Int,    8,
    0x80000000 | 38, QMetaType::Int,    8,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,   40,   24,   26,   27,   28,   29,   30,
    QMetaType::Bool, QMetaType::Int,    8,
    0x80000000 | 36, QMetaType::Int,    8,
    0x80000000 | 38,
    0x80000000 | 38,
    0x80000000 | 38, QMetaType::Int,   20,
    QMetaType::Void,

 // methods: parameters
    0x80000000 | 48,
    0x80000000 | 38, QMetaType::Int, QMetaType::QString,   20,   50,
    0x80000000 | 38, QMetaType::Int, QMetaType::QString,    6,   50,
    QMetaType::Bool, QMetaType::Int,   20,
    QMetaType::Bool, QMetaType::Int,    8,
    QMetaType::Bool, QMetaType::Int,    8,
    QMetaType::Bool, QMetaType::Int,   20,
    QMetaType::Bool, QMetaType::Int,    8,
    QMetaType::Bool,

 // properties: name, type, flags, notifyId, revision
      58, QMetaType::Int, 0x00015103, uint(0), 0,
      59, QMetaType::Bool, 0x00015103, uint(1), 0,
      60, 0x80000000 | 38, 0x00015009, uint(2), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject TaskController::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN14TaskControllerE.offsetsAndSizes,
    qt_meta_data_ZN14TaskControllerE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN14TaskControllerE_t,
        // property 'currentProjectId'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'loading'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'tasks'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<TaskController, std::true_type>,
        // method 'currentProjectIdChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'loadingChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'tasksChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'subTasksChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'taskCreated'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'taskUpdated'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'taskDeleted'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'taskAssigned'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'errorOccurred'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'taskCreationFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'taskUpdateFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'taskDeletionFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'taskAssignmentFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'loadTasksForProject'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'loadTasksForCurrentProject'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'createTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'updateTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'updateTaskStatus'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'deleteTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'assignTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getTaskDetails'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getSubTasks'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'createSubTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'deleteSubTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getTaskHierarchy'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getAvailableEmployees'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'getDepartmentEmployees'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'getTasksForProject'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'onRefreshTimerTimeout'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'getCurrentUser'
        QtPrivate::TypeAndForceComplete<User *, std::false_type>,
        // method 'getTasksForProjectByStatus'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'getSubTasksByStatus'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'canCreateTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'canEditTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'canDeleteTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'canAssignTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'canChangeStatus'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'isEmployeeView'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>
    >,
    nullptr
} };

void TaskController::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<TaskController *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->currentProjectIdChanged(); break;
        case 1: _t->loadingChanged(); break;
        case 2: _t->tasksChanged(); break;
        case 3: _t->subTasksChanged((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 4: _t->taskCreated((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 5: _t->taskUpdated((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 6: _t->taskDeleted((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 7: _t->taskAssigned((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2]))); break;
        case 8: _t->errorOccurred((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 9: _t->taskCreationFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 10: _t->taskUpdateFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 11: _t->taskDeletionFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 12: _t->taskAssignmentFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 13: _t->loadTasksForProject((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 14: _t->loadTasksForCurrentProject(); break;
        case 15: { bool _r = _t->createTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[6])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[7])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[8])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[9])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 16: { bool _r = _t->updateTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[6])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[7])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[8])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 17: { bool _r = _t->updateTaskStatus((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 18: { bool _r = _t->deleteTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 19: { bool _r = _t->assignTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 20: { QVariantMap _r = _t->getTaskDetails((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 21: { QVariantList _r = _t->getSubTasks((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 22: { bool _r = _t->createSubTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[6])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[7])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[8])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 23: { bool _r = _t->deleteSubTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 24: { QVariantMap _r = _t->getTaskHierarchy((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 25: { QVariantList _r = _t->getAvailableEmployees();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 26: { QVariantList _r = _t->getDepartmentEmployees();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 27: { QVariantList _r = _t->getTasksForProject((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 28: _t->onRefreshTimerTimeout(); break;
        case 29: { User* _r = _t->getCurrentUser();
            if (_a[0]) *reinterpret_cast< User**>(_a[0]) = std::move(_r); }  break;
        case 30: { QVariantList _r = _t->getTasksForProjectByStatus((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 31: { QVariantList _r = _t->getSubTasksByStatus((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 32: { bool _r = _t->canCreateTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 33: { bool _r = _t->canEditTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 34: { bool _r = _t->canDeleteTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 35: { bool _r = _t->canAssignTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 36: { bool _r = _t->canChangeStatus((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 37: { bool _r = _t->isEmployeeView();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _q_method_type = void (TaskController::*)();
            if (_q_method_type _q_method = &TaskController::currentProjectIdChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)();
            if (_q_method_type _q_method = &TaskController::loadingChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)();
            if (_q_method_type _q_method = &TaskController::tasksChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int );
            if (_q_method_type _q_method = &TaskController::subTasksChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int );
            if (_q_method_type _q_method = &TaskController::taskCreated; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int );
            if (_q_method_type _q_method = &TaskController::taskUpdated; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 5;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int );
            if (_q_method_type _q_method = &TaskController::taskDeleted; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 6;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int , int );
            if (_q_method_type _q_method = &TaskController::taskAssigned; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 7;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::errorOccurred; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 8;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::taskCreationFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 9;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::taskUpdateFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 10;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::taskDeletionFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 11;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::taskAssignmentFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 12;
                return;
            }
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< int*>(_v) = _t->currentProjectId(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->loading(); break;
        case 2: *reinterpret_cast< QVariantList*>(_v) = _t->tasks(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setCurrentProjectId(*reinterpret_cast< int*>(_v)); break;
        case 1: _t->setLoading(*reinterpret_cast< bool*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *TaskController::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *TaskController::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN14TaskControllerE.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int TaskController::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 38)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 38;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 38)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 38;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    }
    return _id;
}

// SIGNAL 0
void TaskController::currentProjectIdChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void TaskController::loadingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void TaskController::tasksChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void TaskController::subTasksChanged(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void TaskController::taskCreated(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void TaskController::taskUpdated(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void TaskController::taskDeleted(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}

// SIGNAL 7
void TaskController::taskAssigned(int _t1, int _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 7, _a);
}

// SIGNAL 8
void TaskController::errorOccurred(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 8, _a);
}

// SIGNAL 9
void TaskController::taskCreationFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 9, _a);
}

// SIGNAL 10
void TaskController::taskUpdateFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 10, _a);
}

// SIGNAL 11
void TaskController::taskDeletionFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 11, _a);
}

// SIGNAL 12
void TaskController::taskAssignmentFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 12, _a);
}
QT_WARNING_POP
